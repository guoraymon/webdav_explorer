import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webdav_client/webdav_client.dart';
import 'package:webdav_explorer/router_names.dart';
import 'package:webdav_explorer/storage/storage.dart';

import '../common/label_button.dart';
import '../task/task.dart';
import 'file.dart';

class FileListPage extends StatefulWidget {
  final Storage storage;

  const FileListPage({Key? key, required this.storage}) : super(key: key);

  @override
  State<FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<FileListPage> {
  var paths = [];
  AsyncSnapshot<List<File>> _snapshot = const AsyncSnapshot.nothing();

  bool _edit = false;
  final _selects = {};

  @override
  initState() {
    super.initState();
    fetchList();
  }

  fetchList() {
    _snapshot = _snapshot.inState(ConnectionState.waiting);
    widget.storage.client.readDir(paths.join('/')).then((value) {
      final data = value.where((element) => element.name?.indexOf('.') != 0).toList();
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
                  widget.storage.client.mkdir([...paths, nameController.text].join('/')).then((value) {
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
                  return widget.storage.client.remove([...paths, name].join('/')).then((value) {
                    setState(() {
                      _selects.clear();
                      _snapshot.data?.removeWhere((element) => element.name == name);
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
      if (list.isNotEmpty) {
        for (var xFile in list) {
          final uploadPath = [...paths, xFile.name].join('/');
          final uploadTask = UploadTask(widget.storage.client, xFile.path, uploadPath);
          uploadTask.start();
          taskController.addUploadTask(uploadTask);
        }
        Get.toNamed(RouteNames.taskDashboard, arguments: {'initialIndex': 0});
      }
    });
  }

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
          title: Text(paths.isNotEmpty ? paths.last : widget.storage.name),
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
                      IconButton(
                        icon: const Icon(Icons.task_rounded),
                        onPressed: () {
                          Get.toNamed(RouteNames.taskDashboard);
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 32),
                        Text('连接失败'),
                      ],
                    ),
                  );
                }

                final list = _snapshot.data ?? [];
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final myFile = MyFile(widget.storage.client, list[index]);
                    return FileWidget(
                      file: myFile,
                      edit: _edit,
                      select: _selects[index] == true,
                      onSelect: (value) {
                        setState(() {
                          _edit = true;
                          _selects[index] = value;
                        });
                      },
                      onTap: () {
                        if (list[index].isDir == true) {
                          setState(() {
                            paths.add(list[index].name);
                          });
                          fetchList();
                          return;
                        }

                        Get.toNamed(RouteNames.fileDetail, arguments: {
                          'file': MyFile(widget.storage.client, list[index]),
                        });
                      },
                    );
                  },
                );
            }
          }(),
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

class FileWidget extends StatelessWidget {
  final MyFile file;
  final bool edit;
  final bool select;
  final ValueChanged<bool?>? onSelect;
  final GestureTapCallback? onTap;

  const FileWidget({
    Key? key,
    required this.file,
    this.edit = false,
    this.select = false,
    this.onSelect,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final datetime = file.mTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(file.mTime!) : '';
    return ListTile(
      leading: edit ? Checkbox(value: select, onChanged: onSelect) : null,
      title: Row(
        children: [
          FileIconWidget(file: file),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(file.name, overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(datetime),
            ],
          )
        ],
      ),
      onTap: () {
        if (edit) {
          onSelect!(!select);
        } else {
          onTap!();
        }
      },
      onLongPress: () {
        onSelect!(true);
      },
    );
  }
}

class FileIconWidget extends StatelessWidget {
  final MyFile file;

  const FileIconWidget({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (file.isDir == true) {
      return const Icon(Icons.folder_rounded);
    }
    switch (file.type) {
      case FileType.text:
        {
          return const Icon(Icons.text_format_rounded);
        }
      case FileType.image:
        {
          return const Icon(Icons.image_rounded);
        }
      case FileType.music:
        {
          return const Icon(Icons.audio_file_rounded);
        }
      case FileType.video:
        {
          return const Icon(Icons.video_file_rounded);
        }
      default:
        {
          return const Icon(Icons.insert_drive_file_rounded);
        }
    }
  }
}
