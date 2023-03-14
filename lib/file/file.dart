import 'package:webdav_client/webdav_client.dart';

enum FileType { text, image, music, video, unknown }

class MyFile {
  Client client;
  String name;
  String path;

  MyFile(this.client, this.name, this.path);

  FileType get type {
    final ext = name.split('.').last.toLowerCase();
    if (['txt', 'md', 'html', 'xml', 'json', 'csv'].contains(ext)) {
      return FileType.text;
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return FileType.image;
    } else if (['mp3', 'wav', 'flac', 'aac', 'ogg'].contains(ext)) {
      return FileType.music;
    } else if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'].contains(ext)) {
      return FileType.video;
    } else {
      return FileType.unknown;
    }
  }
}
