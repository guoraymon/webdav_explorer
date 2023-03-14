import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/common/helper.dart';

import 'task.dart';

class TaskPage extends StatefulWidget {
  final int initialIndex;

  const TaskPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskController _taskController = Get.put(TaskController());

  bool _edit = false;
  final Map<int, bool> _selects = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务中心'),
        actions: _buildActions(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '上传'),
            Tab(text: '下载'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TaskList(
            tasks: _taskController.uploads,
            edit: _edit,
            selects: _selects,
            onSelect: (index, value) {
              setState(() {
                _edit = true;
                _selects[index] = value;
              });
            },
          ),
          TaskList(
            tasks: _taskController.downloads,
            edit: _edit,
            selects: _selects,
            onSelect: (index, value) {
              setState(() {
                _edit = true;
                _selects[index] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_edit) {
      return [
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            setState(() {
              _edit = false;
              _selects.clear();
            });
          },
        )
      ];
    }
    return [];
  }
}

class TaskList extends StatelessWidget {
  final RxList<Task> tasks;
  final bool edit;
  final Map<int, bool> selects;
  final Function(int index, bool value)? onSelect;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.edit,
    required this.selects,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskWidget(
          task: tasks[index],
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

  final Task task;
  final bool edit;
  final bool select;
  final ValueChanged<bool?>? onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: edit ? Checkbox(value: select, onChanged: onSelect) : null,
      title: Text(
        task.type == TaskType.upload ? task.remotePath : task.localPath,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
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
        return Obx(
          () => Text('${prettyBytes(task.count.toDouble())}/${prettyBytes(task.total.toDouble())}'),
        );
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
