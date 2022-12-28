import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdav_explorer/storage/storage_add.dart';
import 'package:webdav_explorer/storage/storage_edit.dart';
import 'package:webdav_explorer/storage/storage_list.dart';

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
      },
    );
  }
}
