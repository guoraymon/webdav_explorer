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

class TaskController extends GetxController {
  final uploads = [].obs;
  final downloads = [].obs;
}
