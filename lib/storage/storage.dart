import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart';

class Storage {
  String name;
  String url;
  String user;
  String pwd;

  Storage(this.name, this.url, this.user, this.pwd);

  Client? _client;

  Client get client => _client ??= newClient(url, user: user, password: pwd);

  Future<List<File>> readDir(path) async {
    return client.readDir(path);
  }

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      json['name'] as String,
      json['url'] as String,
      json['user'] as String,
      json['pwd'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'user': user,
      'pwd': pwd,
    };
  }
}

class StorageController extends GetxController {
  final _key = 'storage_list';

  final _items = [].obs;

  @override
  void onInit() async {
    super.onInit();
    final prefs = await SharedPreferences.getInstance();
    final res = prefs.getString(_key);
    if (res != null) {
      final data = jsonDecode(res)
          .map<Storage>((json) => Storage.fromJson(json))
          .toList();
      _items.assignAll(data);
    }
  }

  RxList<dynamic> list() {
    return _items;
  }

  Storage get(index) {
    return _items[index];
  }

  Future<bool> add(storage) async {
    _items.add(storage);
    return _save();
  }

  Future<bool> edit(index, storage) async {
    _items[index] = storage;
    return _save();
  }

  Future<bool> del(index) async {
    _items.removeAt(index);
    return _save();
  }

  Future<bool> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(_items));
    return true;
  }
}
