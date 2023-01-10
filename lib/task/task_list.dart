import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/task/task.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    final uploadTaskController = Get.put(UploadTaskController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('任务中心'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.upload_file_rounded, color: Colors.black)),
              Tab(icon: Icon(Icons.downloading_rounded, color: Colors.black)),
            ],
          ),
        ),
        body: Obx(
          () => TabBarView(
            children: [
              ListView.builder(
                itemCount: uploadTaskController.length(),
                itemBuilder: (context, index) {
                  final uploadTask = uploadTaskController.get(index);
                  return Row(
                    children: [
                      Text(uploadTask.name),
                      Text(
                          '${(uploadTask.count / uploadTask.total * 100).toInt()}%'),
                    ],
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
