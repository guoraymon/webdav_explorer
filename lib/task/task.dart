import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:webdav_client/webdav_client.dart';

enum TaskState {
  none,
  running,
  completed,
  cancelled,
}

class UploadTask {
  Client client;
  TaskState state = TaskState.none;
  late String localPath;
  late String remotePath;
  late CancelToken _cancelToken;
  int count = 0;
  int total = 0;
  int speed = 0;
  int _speedCount = 0;

  UploadTask(this.client);

  /// 上传
  upload(String localPath, String remotePath) {
    this.localPath = localPath;
    this.remotePath = remotePath;
    start();
  }

  start() {
    state = TaskState.running;
    _cancelToken = CancelToken();
    client.writeFromFile(
      localPath,
      remotePath,
      onProgress: (c, t) {
        count = c;
        total = t;
        if (c == t) {
          state = TaskState.completed;
        }
      },
      cancelToken: _cancelToken,
    );
  }

  cancel() {
    _cancelToken.cancel();
    state = TaskState.cancelled;
  }

  bool isFinish() {
    return state == TaskState.completed;
  }

  void refreshSpeed() {
    speed = count - _speedCount;
    _speedCount = count;
  }

  /// 获取进度
  double getProgress() {
    if (count > 0 && total > 0) {
      return count / total;
    }
    return 0;
  }

  /// 获取剩余
  int getRemain() {
    return total - count;
  }
}

class Task {
  TaskState state = TaskState.none;

  String name;
  String path;
  int count = 0;
  int _count = 0;
  int total = 0;
  int speed = 0;

  CancelToken? cancelToken;

  Task(this.name, this.path, {this.cancelToken}) {
    state = TaskState.running;
  }

  void refreshSpeed() {
    speed = count - _count;
    _count = count;
  }

  bool isFinish() {
    return count >= total;
  }

  double getProgress() {
    return count / total;
  }

  int getRemain() {
    return total - count;
  }

  cancel() {
    cancelToken?.cancel();
  }
}

enum TaskType {
  download,
  upload,
}

class TaskController extends GetxController {
  final RxList<UploadTask> uploads = <UploadTask>[].obs;
  final downloads = [].obs;
}
