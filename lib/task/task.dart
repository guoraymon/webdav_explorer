import 'package:get/get.dart';

class Task {
  String name;
  String path;
  int count = 0;
  int total = 0;

  Task(this.name, this.path);
}

enum TaskType {
  download,
  upload,
}

class TaskController extends GetxController {
  final uploads = [].obs;
  final downloads = [].obs;
}
