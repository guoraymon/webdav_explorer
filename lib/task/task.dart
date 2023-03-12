import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:webdav_client/webdav_client.dart';

enum TaskType {
  download, // 下载任务
  upload, // 上传任务
}

enum TaskState {
  none, // 无状态
  running, // 运行中
  completed, // 完成
  cancelled, // 已取消
}

abstract class Task extends GetxController {
  final Client client; // WebDAV 客户端
  final TaskType type; // 任务类型
  final String localPath; // 本地路径
  final String remotePath; // 远程路径

  final Rx<TaskState> state = TaskState.none.obs; // 当前任务状态（响应式变量）
  CancelToken? _cancelToken; // 取消令牌

  RxDouble total = 0.0.obs; // 总数（响应式变量）
  RxDouble count = 0.0.obs; // 计数（响应式变量）
  RxDouble speed = 0.0.obs; // 速度（响应式变量）

  Timer? _timer; // 定时器
  double _lastCount = 0.0; // 上次的计数值

  Task(this.client, this.type, this.localPath, this.remotePath);

  @override
  void onClose() {
    super.onClose();
    _cancelToken?.cancel();
    _cancelTimer();
  }

  /// 开始任务
  void start() {
    state.value = TaskState.running;
    count.value = 0;
    total.value = 0;
    speed.value = 0;
    _lastCount = 0;

    _cancelToken = CancelToken();
    client.writeFromFile(
      localPath,
      remotePath,
      onProgress: (c, t) {
        count.value = c.toDouble();
        total.value = t.toDouble();
        if (c == t) {
          state.value = TaskState.completed;
          _cancelTimer();
        }
      },
      cancelToken: _cancelToken,
    );

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      speed.value = count.value - _lastCount;
      _lastCount = count.value;
    });
  }

  /// 取消
  void cancel() {
    state.value = TaskState.cancelled;
    _cancelToken?.cancel();
    _cancelTimer();
  }

  /// 获取进度
  double getProgress() {
    if (count.value > 0 && total.value > 0) {
      return count.value / total.value;
    }
    return 0;
  }

  /// 获取预计剩余时间
  int getETA() {
    if (speed.value > 0) {
      return (total.value - count.value) ~/ speed.value;
    }
    return 0;
  }

  /// 取消定时器
  void _cancelTimer() {
    var timer = _timer;
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }
}

class UploadTask extends Task {
  UploadTask(Client client, localPath, String remotePath) : super(client, TaskType.upload, localPath, remotePath);
}

class DownloadTask extends Task {
  DownloadTask(Client client, String localPath, String remotePath)
      : super(client, TaskType.download, localPath, remotePath);
}

class TaskController extends GetxController {
  final RxList<UploadTask> uploads = <UploadTask>[].obs;
  final RxList<UploadTask> downloads = <UploadTask>[].obs;
}
