import 'package:get/get.dart';

class Task {
  String name;
  int count = 0;
  int total = 0;

  Task(this.name);
}

enum TaskType {
  download,
  upload,
}

abstract class TaskController extends GetxController {
  final _items = [].obs;

  RxList list() {
    return _items;
  }

  int length() {
    return _items.length;
  }

  Rx<Task> get(index) {
    return _items[index];
  }

  add(Rx<Task> item) {
    _items.add(item);
  }
}

class UploadTaskController extends TaskController {}

class DownloadTaskController extends TaskController {}
