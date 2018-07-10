
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class IBStorage {

  static var reference =  FirebaseStorage.instance.ref();

  static upload(File file, String id, {int index = 0}) async {
    var metadata = StorageMetadata(contentType: "image/jpg");
    reference.child(id).child("image$index").putFile(file, metadata);
  }

  static Future<dynamic> getDownloadUrl(String id, {int index = 0}) async {
    var completer = Completer<dynamic>();
    try {
      var url = await reference.child(id).child("image$index").getDownloadURL();
      completer.complete(url);
    }
    catch(e) {
      print(e);
      completer.complete(null);
    }
    return completer.future;
  }
}