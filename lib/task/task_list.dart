import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/task/task.dart';

import '../common/helper.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
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
              Tab(icon: Icon(Icons.downloading_rounded, color: Colors.black)),
            ],
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              ListView.builder(
                itemCount: taskController.uploads.length,
                itemBuilder: (context, index) {
                  final task = taskController.uploads[index];
                  final per = (task.count / task.total * 100).toInt();
                  return ListTile(
                    title: Text(task.name),
                    subtitle: Text(
                        '${humanReadableByte(task.count)}/${humanReadableByte(task.total)} $per%'),
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
