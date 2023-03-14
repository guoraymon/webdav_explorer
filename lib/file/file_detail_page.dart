import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webdav_explorer/common/label_button.dart';
import 'package:webdav_explorer/file/file.dart';
import 'package:webdav_explorer/router_paths.dart';
import 'package:webdav_explorer/task/task.dart';

class FileDetailPage extends StatelessWidget {
  final MyFile file;

  FileDetailPage({Key? key, required this.file}) : super(key: key);

  final _taskController = Get.put(TaskController());

  /// 打开
  open() async {
    final temporaryDirectory = await getTemporaryDirectory();
    final tempPath = '${temporaryDirectory.path}/${file.name}';

    final tmpFile = File(tempPath);
    await tmpFile.writeAsBytes(await file.client.read(file.path));
    launchUrl(Uri.parse('file:${tmpFile.path}'));
  }

  /// 下载
  download() async {
    // 获取用户的下载目录路径
    final downloadsDirectory = Directory('/Users/${Platform.environment['USER']}/Downloads');
    // final downloadsDirectory = await getDownloadsDirectory();
    final downloadPath = '${downloadsDirectory.path}/${file.name}';

    final downTask = DownloadTask(file.client, downloadPath, file.path);
    downTask.start();
    _taskController.addDownTask(downTask);

    Get.toNamed(RoutePaths.taskDashboard, arguments: {'initialIndex': 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
      ),
      body: Container(
        alignment: Alignment.center,
        child: file.type == FileType.image
            ? Image.network(
                [file.client.uri, file.path].join('/'),
                headers: {
                  'Authorization': file.client.auth.authorize('', '') ?? '',
                },
              )
            : null,
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: LabelButton(
              icon: Icons.file_open_rounded,
              label: '打开',
              onTap: open,
            ),
          ),
          Expanded(
            child: LabelButton(
              icon: Icons.file_open_rounded,
              label: '下载',
              onTap: download,
            ),
          ),
        ],
      ),
    );
  }
}
