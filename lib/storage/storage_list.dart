import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/router_names.dart';
import 'package:webdav_explorer/storage/storage.dart';
import 'package:webdav_explorer/common/label_button.dart';

class StorageList extends StatefulWidget {
  const StorageList({Key? key}) : super(key: key);

  @override
  State<StorageList> createState() => _StorageListState();
}

class _StorageListState extends State<StorageList> {
  bool _edit = false;
  int? _select;

  @override
  Widget build(BuildContext context) {
    final storageController = Get.put(StorageController());
    return WillPopScope(
      onWillPop: () async {
        if (_edit) {
          setState(() {
            _edit = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WebDAV'),
          centerTitle: true,
          actions: [
            _edit
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _edit = false;
                      });
                    },
                    child: const Text('取消'),
                  )
                : IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: '添加',
                    onPressed: () {
                      Get.toNamed('storage_add');
                    },
                  )
          ],
        ),
        body: Obx(
          () => ListView.builder(
            itemCount: storageController.list().length,
            itemBuilder: (context, index) {
              final storage = storageController.get(index);
              return ListTile(
                title: Text(storage.name),
                subtitle: Text(storage.url),
                leading: _edit
                    ? Radio(
                        value: index,
                        groupValue: _select,
                        onChanged: (int? value) {
                          setState(() {
                            _select = index;
                          });
                        },
                      )
                    : null,
                onTap: () {
                  if (_edit) {
                    setState(() {
                      _select = index;
                    });
                  } else {
                    Get.toNamed(RouteNames.fileList, arguments: storage);
                  }
                },
                onLongPress: () {
                  setState(() {
                    _edit = true;
                    _select = index;
                  });
                },
              );
            },
          ),
        ),
        bottomNavigationBar: _edit
            ? Row(
                children: [
                  Expanded(
                    child: LabelButton(
                      icon: Icons.edit_rounded,
                      label: '编辑',
                      onTap: () {
                        Get.toNamed('storage_edit', arguments: _select)
                            ?.then((res) {
                          if (res) {
                            setState(() {
                              _edit = false;
                            });
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: LabelButton(
                      icon: Icons.delete_rounded,
                      label: '删除',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('提示'),
                              content: const Text('确认删除吗？'),
                              actions: [
                                TextButton(
                                    child: const Text('确认'),
                                    onPressed: () {
                                      storageController
                                          .del(_select)
                                          .then((value) {
                                        setState(() {
                                          _edit = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(content: Text('删除成功')),
                                        );
                                      });
                                      Get.back();
                                    }),
                                TextButton(
                                    child: const Text('取消'),
                                    onPressed: () => Get.back()),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
