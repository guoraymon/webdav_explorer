import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:webdav_client/webdav_client.dart';

enum TaskType {
  download,
  upload,
}

enum TaskState {
  none,
  running,
  completed,
  cancelled,
}

class UploadTask extends GetxController {
  Client client;

  Rx<TaskState> state = TaskState.none.obs;
  String localPath;
  String remotePath;
  late CancelToken _cancelToken;

  RxDouble total = 0.0.obs;
  RxDouble count = 0.0.obs;
  RxDouble speed = 0.0.obs;

  Timer? _timer;
  double _lastCount = 0.0;

  UploadTask(this.client, this.localPath, this.remotePath);

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
          _timer?.cancel();
          _timer = null;
        }
      },
      cancelToken: _cancelToken,
    );

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      speed.value = count.value - _lastCount;
      _lastCount = count.value;
    });
  }

  void cancel() {
    state.value = TaskState.cancelled;
    _cancelToken.cancel();
    _timer?.cancel();
    _timer = null;
  }

  /// 获取进度
  double getProgress() {
    if (total.value > 0) {
      return count.value / total.value;
    }
    return 0;
  }

  /// 获取预计剩余时间
  getETA() {
    return (total.value - count.value) ~/ speed.value;
  }
}

class TaskController extends GetxController {
  var uploads = <UploadTask>[].obs;

  ///dev
  final downloads = [].obs;
}
