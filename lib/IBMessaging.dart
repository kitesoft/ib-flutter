
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

import 'package:ib/IBDefaults.dart';

class IBMessaging {

  static var instance = new FirebaseMessaging();

  static var serverKey = "AAAAa7QO-FQ:APA91bFoGBEuQj26c_cfWS9I0VfCFMdZrP_EYR40Cb4eu-gUOSNKumgiIyIZJkljBhxGHBSWwOmrgC8ewxjCsvhQ5oxTMfW_p6BHGDXNSSLR5j1G8n8VvobJAsWxV0TmNtylKm2RfSAS-svxWw6bbZTABHfsLNucZg";
  static var url = "https://fcm.googleapis.com/fcm/send";

  static String token;

  static Future<String> getToken() async{

    var completer = new Completer<String>();

    IBMessaging.token = await instance.getToken();

    completer.complete(token);

    return completer.future;
  }

  static Future send(String title, String body, Map data, String token) {

    var completer = new Completer();

    var requestUrl = url;

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.CONTENT_TYPE] = "application/json";
    request.headers[HttpHeaders.AUTHORIZATION] = "key=$serverKey";

    data.addAll({
      "click_action" : "FLUTTER_NOTIFICATION_CLICK",
      "id" : "1",
      "status" : "done"
    });

    request.body = json.encode({
      "notification" : {
        "body" : body,
        "title" : token
      },
      "priority" : "high",
      "data" : data,
      "to" : token
    });

    client.send(request).then((response) {
      response.stream.bytesToString().then((resultStr) {
        print(resultStr);
        return completer.complete(resultStr);
      });
    }).catchError((error) {
      print(error.toString());
    });

    return completer.future;
  }
}