import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/task/task.dart';

import '../common/helper.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final taskController = Get.put(TaskController());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var task in taskController.uploads as RxList<Task>) {
        task.refreshSpeed();
      }
      taskController.uploads.refresh();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.put(TaskController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('任务中心'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.upload_rounded, color: Colors.black)),
              Tab(icon: Icon(Icons.download_rounded, color: Colors.black)),
            ],
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              ListView.builder(
                itemCount: taskController.uploads.length,
                itemBuilder: (context, index) {
                  final Task task = taskController.uploads[index];
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Column(
                      children: [
                        LinearProgressIndicator(value: task.getProgress()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${prettyBytes(task.count.toDouble())}/${prettyBytes(task.total.toDouble())}'),
                            task.isFinish()
                                ? const Text('已完成')
                                : Row(
                                    children: [
                                      Text(
                                          '${prettyBytes(task.speed.toDouble())}/s'),
                                      const Gap(4),
                                      Text(task.speed > 0
                                          ? prettySeconds(
                                              task.getRemain() ~/ task.speed)
                                          : '未知')
                                    ],
                                  )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Center(
                child: Text('下载任务'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
