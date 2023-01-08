import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:webdav_client/webdav_client.dart';

import '../common/label_button.dart';
import '../storage/storage.dart';

class FileList extends StatefulWidget {
  const FileList({Key? key}) : super(key: key);

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  late Storage storage;
  var paths = [];
  bool _edit = false;
  final _selects = {};
  late Future<List<File>> _futureBuilderFuture;

  @override
  initState() {
    storage = Get.arguments as Storage;
    _futureBuilderFuture = _getData();
    super.initState();
  }

  Future<List<File>> _getData() async {
    var files = await storage.readDir(paths.join('/'));
    return files.where((element) => element.name?.indexOf('.') != 0).toList();
  }

  createDir() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    Future.delayed(
      Duration.zero,
      () => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('新建文件夹'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '文件夹名称'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '文件夹名称不能为空';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('确定'),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    storage.client
                        .mkdir([...paths, nameController.text].join('/'))
                        .then((value) {
                      setState(() {
                        _futureBuilderFuture = _getData();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('新建文件夹成功')),
                      );
                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (paths.isNotEmpty) {
          setState(() {
            paths.removeLast();
            _futureBuilderFuture = _getData();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(paths.isNotEmpty ? paths.last : storage.name),
          actions: [
            _edit
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _edit = false;
                        _selects.clear();
                      });
                    },
                    child: const Text('取消'),
                  )
                : PopupMenuButton(
                    itemBuilder: (BuildContext context1) => [
                      PopupMenuItem(
                        onTap: createDir,
                        child: const Text('新建文件夹'),
                      ),
                      PopupMenuItem(
                        child: const Text('上传文件'),
                        onTap: () {},
                      ),
                    ],
                  )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
              var list = snapshot.data ?? [];
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error, color: Colors.red, size: 32),
                          Text('连接失败'),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final file = list[index];
                      return InkWell(
                        onTap: () {
                          if (_edit) {
                            setState(() {
                              if (_selects[index] == true) {
                                _selects.remove(index);
                              } else {
                                _selects[index] = true;
                              }
                            });
                          } else {
                            if (file.isDir == true) {
                              setState(() {
                                paths.add(file.name);
                                _futureBuilderFuture = _getData();
                              });
                              return;
                            }

                            final mime = lookupMimeType(file.name!);
                            if (mime?.indexOf('image/') == 0) {
                              Get.toNamed('file_preview', arguments: {
                                'storage': storage,
                                'file': file
                              });
                            }
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _edit = true;
                            _selects[index] = true;
                          });
                        },
                        child: GridTile(
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                child: lookupMimeType(file.name!)
                                            ?.indexOf('image/') ==
                                        0
                                    ? Image.network(
                                        storage.url + file.path!,
                                        headers: {
                                          'Authorization':
                                              'Basic ${base64Encode(utf8.encode('${storage.user}:${storage.pwd}'))}',
                                        },
                                        fit: BoxFit.cover,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              file.isDir == true
                                                  ? Icons.folder_rounded
                                                  : Icons.question_mark_rounded,
                                              size: 64),
                                          Text(
                                            file.name!,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                              ),
                              if (_edit)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Checkbox(
                                    value: _selects[index] ?? false,
                                    onChanged: (bool? value) {},
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
              }
            },
          ),
        ),
        bottomNavigationBar: _edit
            ? Row(
                children: [
                  Expanded(
                    child: LabelButton(
                      icon: Icons.move_up_rounded,
                      label: '移动',
                      onTap: _selects.isNotEmpty
                          ? () {
                              print('移动');
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: LabelButton(
                      icon: Icons.copy_rounded,
                      label: '复制',
                      onTap: _selects.isNotEmpty
                          ? () {
                              print('复制');
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: LabelButton(
                      icon: Icons.delete_rounded,
                      label: '删除',
                      onTap: _selects.isNotEmpty
                          ? () {
                              print('删除');
                            }
                          : null,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
