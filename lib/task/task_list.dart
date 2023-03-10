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

  bool _edit = false;
  final _selects = {};

  @override
  void initState() {
    super.initState();
    final taskController = Get.put(TaskController());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var task in taskController.uploads) {
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
          actions: [
            if (_edit)
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  setState(() {
                    _edit = false;
                    _selects.clear();
                  });
                },
              ),
          ],
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
                  final UploadTask task = taskController.uploads[index];
                  return TaskWidget(
                    task: task,
                    edit: _edit,
                    select: _selects[index] == true,
                    onSelect: (value) {
                      setState(() {
                        _selects[index] = value;
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        _edit = true;
                        _selects[index] = true;
                      });
                    },
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

class TaskWidget extends StatelessWidget {
  const TaskWidget({
    Key? key,
    required this.task,
    this.edit = false,
    this.select = false,
    this.onSelect,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final UploadTask task;
  final bool edit;
  final bool select;
  final ValueChanged<bool?>? onSelect;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: edit ? Checkbox(value: select, onChanged: onSelect) : null,
      title: Text(task.remotePath),
      subtitle: Column(
        children: [
          LinearProgressIndicator(value: task.getProgress()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${prettyBytes(task.count.toDouble())}/${prettyBytes(task.total.toDouble())}'),
              if (task.state == TaskState.running)
                Row(
                  children: [
                    Text('${prettyBytes(task.speed.toDouble())}/s'),
                    const Gap(4),
                    Text(task.speed > 0
                        ? prettySeconds(task.getRemain() ~/ task.speed)
                        : '未知')
                  ],
                )
              else if (task.state == TaskState.completed)
                const Text('已完成')
            ],
          ),
        ],
      ),
      trailing: TaskActionWidget(task),
      onTap: () {
        if (edit) {
          onSelect!(!select);
        } else {
          onTap!();
        }
      },
      onLongPress: onLongPress,
    );
  }
}

class TaskActionWidget extends StatelessWidget {
  const TaskActionWidget(this.task, {Key? key}) : super(key: key);

  final UploadTask task;

  @override
  Widget build(BuildContext context) {
    switch (task.state) {
      case TaskState.running:
        return IconButton(
          icon: const Icon(Icons.cancel_rounded),
          tooltip: '取消',
          onPressed: () {
            task.cancel();
          },
        );
      case TaskState.completed:
        return IconButton(
          icon: const Icon(Icons.done_rounded),
          tooltip: '已完成',
          onPressed: () {},
        );
      case TaskState.cancelled:
        return IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: '重试',
          onPressed: () {
            task.upload(task.localPath, task.remotePath);
          },
        );
      default:
        return IconButton(
          icon: const Icon(Icons.error_rounded),
          tooltip: '出错了',
          onPressed: () {},
        );
    }
  }
}
