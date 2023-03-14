import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/file/file.dart';
import 'package:webdav_explorer/file/file_detail_page.dart';
import 'package:webdav_explorer/file/file_list_page.dart';
import 'package:webdav_explorer/router_names.dart';
import 'package:webdav_explorer/storage/storage_add.dart';
import 'package:webdav_explorer/storage/storage_edit.dart';
import 'package:webdav_explorer/storage/storage_list.dart';
import 'package:webdav_explorer/task/task_page.dart';

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
        RouteNames.fileList: (context) => const FileListPage(),
        RouteNames.fileDetail: (context) => FileDetailPage(file: Get.arguments['file'] as MyFile),
        RouteNames.taskDashboard: (context) => TaskDashboardPage(initialIndex: Get.arguments['initialIndex'] as int),
      },
    );
  }
}
