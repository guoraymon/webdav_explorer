import 'package:get/get.dart';

class Task {
  String name;
  String path;
  int count = 0;
  int _count = 0;
  int total = 0;
  int speed = 0;

  Task(this.name, this.path);

  refreshSpeed() {
    speed = count - _count;
    _count = count;
  }

  isFinish() {
    return count >= total;
  }

  getProgress() {
    return count / total;
  }

  getRemain() {
    return total - count;
  }
}

enum TaskType {
  download,
  upload,
}

class TaskController extends GetxController {
  final uploads = [].obs;
  final downloads = [].obs;
}
