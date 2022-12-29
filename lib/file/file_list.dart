import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:webdav_client/webdav_client.dart';

import '../storage/storage.dart';

class FileList extends StatefulWidget {
  const FileList({Key? key}) : super(key: key);

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  late Storage storage;
  var paths = [];

  @override
  initState() {
    storage = Get.arguments as Storage;
    super.initState();
  }

  Future<List<File>> _getData() async {
    var files = await storage.readDir(paths.join('/'));
    print(files);
    return files.where((element) => element.name?.indexOf('.') != 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (paths.isNotEmpty) {
          setState(() {
            paths.removeLast();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(paths.isNotEmpty ? paths.last : storage.name),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder(
            future: _getData(),
            builder:
                (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
              var list = snapshot.data ?? [];
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.error, color: Colors.red, size: 32),
                          Text('连接失败'),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final file = list[index];
                      return InkWell(
                        onTap: () {
                          if (file.isDir == true) {
                            setState(() {
                              paths.add(file.name);
                            });
                            return;
                          }

                          final mime = lookupMimeType(file.name!);
                          if (mime?.indexOf('image/') == 0) {
                            Get.toNamed('file_preview',
                                arguments: {'storage': storage, 'file': file});
                          }
                        },
                        child: GridTile(
                          child:
                              lookupMimeType(file.name!)?.indexOf('image/') == 0
                                  ? Image.network(
                                      storage.url + file.path!,
                                      headers: {
                                        'Authorization':
                                            'Basic ${base64Encode(utf8.encode('${storage.user}:${storage.pwd}'))}',
                                      },
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            file.isDir == true
                                                ? Icons.folder_rounded
                                                : Icons.question_mark_rounded,
                                            size: 64),
                                        Text(
                                          file.name!,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                        ),
                      );
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
