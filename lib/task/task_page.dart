import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/task/task.dart';

import '../common/helper.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool _edit = false;
  final Map<int, bool> _selects = {};

  @override
  Widget build(BuildContext context) {
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
        body: TabBarView(
          children: [
            TaskList(
              edit: _edit,
              selects: _selects,
              onSelect: (index, value) {
                setState(() {
                  _edit = true;
                  _selects[index] = value;
                });
              },
            ),
            const Center(
              child: Text('下载任务'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final bool edit;
  final Map<int, bool> selects;
  final Function(int index, bool value)? onSelect;

  const TaskList(
      {Key? key, required this.edit, required this.selects, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskController = Get.put(TaskController());
    return ListView.builder(
      itemCount: taskController.uploads.length,
      itemBuilder: (context, index) {
        final UploadTask task = taskController.uploads[index];
        return TaskWidget(
          task: task,
          edit: edit,
          select: selects[index] == true,
          onSelect: (value) {
            onSelect!(index, value!);
          },
        );
      },
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
  }) : super(key: key);

  final UploadTask task;
  final bool edit;
  final bool select;
  final ValueChanged<bool?>? onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: edit ? Checkbox(value: select, onChanged: onSelect) : null,
      title: Text(task.remotePath),
      subtitle: Column(
        children: [
          Obx(() => LinearProgressIndicator(value: task.getProgress())),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _buildDesc()),
              Obx(() => _buildState()),
            ],
          ),
        ],
      ),
      trailing: Obx(() => _buildAction()),
      onTap: () {
        if (edit) {
          onSelect!(!select);
        }
      },
      onLongPress: () {
        onSelect!(true);
      },
    );
  }

  Widget _buildDesc() {
    switch (task.state.value) {
      case TaskState.running:
      case TaskState.completed:
        return Obx(() => Text(
            '${prettyBytes(task.count.toDouble())}/${prettyBytes(task.total.toDouble())}'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildState() {
    switch (task.state.value) {
      case TaskState.running:
        return Row(
          children: [
            Text('${prettyBytes(task.speed.value)}/s'),
            const Gap(4),
            if (task.speed.value > 0) Text('${prettySeconds(task.getETA())}')
          ],
        );
      case TaskState.completed:
        return const Text('已完成');
      case TaskState.cancelled:
        return const Text('已取消');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAction() {
    switch (task.state.value) {
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
            task.start();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
