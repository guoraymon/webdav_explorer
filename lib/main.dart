import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'file/file.dart';
import 'file/file_detail_page.dart';
import 'file/file_list_page.dart';
import 'router_paths.dart';
import 'storage/storage_add.dart';
import 'storage/storage_edit.dart';
import 'storage/storage_list.dart';
import 'task/task_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Webdav Explorer',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: 'storage_list',
      routes: {
        'storage_list': (context) => const StorageList(),
        'storage_add': (context) => const StorageAdd(),
        'storage_edit': (context) => const StorageEdit(),
        RoutePaths.fileList: (context) => const FileListPage(),
        RoutePaths.fileDetail: (context) => FileDetailPage(file: Get.arguments['file'] as MyFile),
        RoutePaths.taskDashboard: (context) => TaskDashboardPage(initialIndex: Get.arguments['initialIndex'] as int),
      },
    );
  }
}
