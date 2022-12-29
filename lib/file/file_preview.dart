import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:webdav_explorer/common/label_button.dart';

import '../storage/storage.dart';

class FilePreview extends StatefulWidget {
  const FilePreview({Key? key}) : super(key: key);

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  late Storage storage;
  late webdav.File file;

  @override
  initState() {
    storage = Get.arguments['storage'] as Storage;
    file = Get.arguments['file'] as webdav.File;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name!),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Image.network(
          [storage.url, file.path!].join('/'),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('${storage.user}:${storage.pwd}'))}',
          },
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: LabelButton(
              icon: Icons.file_open_rounded,
              label: '打开',
              onTap: () async {
                Directory tempDir = await getTemporaryDirectory();
                String tempPath = tempDir.path;

                File tmpFile = File('$tempPath/${file.name}');
                await tmpFile
                    .writeAsBytes(await storage.client.read(file.path!));

                final url = Uri.parse('file:${tmpFile.path}');
                if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
