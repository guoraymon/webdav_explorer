import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:webdav_client/webdav_client.dart';

import '../common/label_button.dart';
import '../storage/storage.dart';
import '../task/task.dart';

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

  late AsyncSnapshot<List<File>> _snapshot;

  @override
  initState() {
    super.initState();
    storage = Get.arguments as Storage;
    setState(() {
      _snapshot = const AsyncSnapshot.nothing();
    });
    fetchList();
  }

  fetchList() {
    _snapshot = _snapshot.inState(ConnectionState.waiting);
    storage.readDir(paths.join('/')).then((value) {
      final data =
          value.where((element) => element.name?.indexOf('.') != 0).toList();
      setState(() {
        _snapshot = AsyncSnapshot.withData(ConnectionState.done, data);
      });
    });
  }

  /// Create folder
  mkdir() {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
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
                  //TODO::处理请求结果
                  storage.client
                      .mkdir([...paths, nameController.text].join('/'))
                      .then((value) {
                    setState(() {
                      //TODO::实现单更
                      fetchList();
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
    );
  }

  /// Remove a folder or file
  remove() {
    showDialog(
      context: context,
      builder: (context) {
        final list = _selects.entries.map((e) => _snapshot.data![e.key].name);
        return AlertDialog(
          title: const Text('删除文件'),
          content: Text('确定要删除 ${list.join(',')} ?'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Future.wait(list.map((name) {
                  return storage.client
                      .remove([...paths, name].join('/'))
                      .then((value) {
                    setState(() {
                      _selects.clear();
                      _snapshot.data
                          ?.removeWhere((element) => element.name == name);
                    });
                  });
                })).then((value) {
                  setState(() {
                    _edit = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// Remove a folder or file
  upload() {
    final taskController = Get.put(TaskController());
    openFiles().then((list) {
      for (var xFile in list) {
        final uploadPath = [...paths, xFile.name].join('/');
        final uploadTask = UploadTask(storage.client, xFile.path, uploadPath);
        taskController.uploads.add(uploadTask);
        uploadTask.start();
      }
      Get.toNamed('taskPage');
    });
  }

  test() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_edit) {
          setState(() {
            _edit = false;
            _selects.clear();
          });
          return false;
        } else {
          if (paths.isNotEmpty) {
            setState(() {
              paths.removeLast();
              // _futureBuilderFuture = _getData();
            });
            fetchList();
            return false;
          }
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
                : Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Future.delayed(Duration.zero, () => test());
                        },
                        child: const Text('测试'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.task_rounded),
                        onPressed: () {
                          Get.toNamed('taskPage');
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (BuildContext context1) => [
                          PopupMenuItem(
                            onTap: () {
                              Future.delayed(Duration.zero, () => mkdir());
                            },
                            child: const Text('新建文件夹'),
                          ),
                          PopupMenuItem(
                            child: const Text('上传文件'),
                            onTap: () {
                              Future.delayed(Duration.zero, () => upload());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: () {
            switch (_snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (_snapshot.hasError) {
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

                final list = _snapshot.data ?? [];
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            });
                            fetchList();
                            // _getData().then((value) => setState((){
                            //   list = value;
                            // }));
                            return;
                          }

                          final mime = lookupMimeType(file.name!);
                          if (mime?.indexOf('image/') == 0) {
                            Get.toNamed('file_preview',
                                arguments: {'storage': storage, 'file': file});
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
          }(),
          // child: FutureBuilder(
          //   future: _futureBuilderFuture,
          //   builder:
          //       (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
          //     var list = snapshot.data ?? [];

          //   },
          // ),
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
                      onTap: _selects.isNotEmpty ? remove : null,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
