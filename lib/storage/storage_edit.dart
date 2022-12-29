import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage.dart';

class StorageEdit extends StatefulWidget {
  const StorageEdit({Key? key}) : super(key: key);

  @override
  State<StorageEdit> createState() => _EditStoragePageState();
}

class _EditStoragePageState extends State<StorageEdit> {
  final StorageController storageController = Get.put(StorageController());

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final urlController = TextEditingController();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  onPressed() {
    if (_formKey.currentState!.validate()) {
      final index = Get.arguments as int;
      final storage = Storage(nameController.text, urlController.text,
          userController.text, pwdController.text);
      storageController.edit(index, storage).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        Get.back(result: true);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final storage = storageController.get(Get.arguments as int);
    nameController.text = storage.name;
    urlController.text = storage.url;
    userController.text = storage.user;
    pwdController.text = storage.pwd;
  }

  @override
  void dispose() {
    nameController.dispose();
    urlController.dispose();
    userController.dispose();
    pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('编辑储存库'),
          actions: [
            IconButton(onPressed: onPressed, icon: const Icon(Icons.done))
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '名称'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存库名称';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: '地址'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存库地址';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: userController,
                  decoration: const InputDecoration(labelText: '用户名'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存库用户名';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: pwdController,
                  decoration: const InputDecoration(labelText: '密码'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存库密码';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
