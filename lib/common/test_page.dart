import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../task/task.dart';
import 'helper.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    final taskController = Get.put(TaskController());
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                final task = Task('测试1');
                taskController.uploads.add(task);

                int count = 0;
                Timer.periodic(const Duration(seconds: 1), (timer) {
                  task.total += 100;
                  taskController.uploads.refresh();
                  if (++count >= 5) {
                    timer.cancel();
                  }
                });
              },
              child: const Text('测试'))
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: taskController.uploads.length,
          itemBuilder: (context, index) {
            final uploadTask = taskController.uploads[index];
            final per =
                uploadTask.count != 0 && uploadTask.count != 0
                    ? (uploadTask.count / uploadTask.total * 100)
                        .toInt()
                    : 0;
            return ListTile(
              title: Text(uploadTask.name),
              subtitle: Text(
                  '${humanReadableByte(uploadTask.count)}/${humanReadableByte(uploadTask.total)} $per%'),
            );
          },
        ),
      ),
    );
  }
}
