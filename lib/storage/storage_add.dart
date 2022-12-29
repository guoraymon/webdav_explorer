import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'storage.dart';

class StorageAdd extends StatefulWidget {
  const StorageAdd({Key? key}) : super(key: key);

  @override
  State<StorageAdd> createState() => _StorageAddState();
}

class _StorageAddState extends State<StorageAdd> {
  final StorageController storageController = Get.put(StorageController());

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final urlController = TextEditingController();
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  onPressed() {
    if (_formKey.currentState!.validate()) {
      final storage = Storage(nameController.text, urlController.text,
          userController.text, pwdController.text);

      storageController.add(storage).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加成功')),
        );
        Get.back();
      });
    }
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
          title: const Text('添加储存库'),
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
