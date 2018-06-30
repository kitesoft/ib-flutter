
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:ib/IBLocalString.dart';
import 'package:ib/GooglePlace.dart';

class GoogleAPI {

  static var googleApiUrl = "https://maps.googleapis.com/maps/api";
  static var apiKey = "AIzaSyB4nKadSSVkj3kia6AzHEekqyissV2Dfhk";

  static var autocompleteRadiusBias = 1000; // in meters

  static Future<List<GooglePlace>> autocomplete({double lat, double lon, String text = "test"}) async {

    var completer = new Completer<List<GooglePlace>>();

    var requestUrl = "$googleApiUrl/place/autocomplete/json?input=$text&radius=$autocompleteRadiusBias&location=$lat,$lon&language=es&key=$apiKey";

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.CONTENT_TYPE] = "application/json";

    client.send(request).then((response) {
      response.stream.bytesToString().then((resultStr) {
        var jsonResult = json.decode(resultStr);
        var predictions = jsonResult["predictions"];
        var places = List<GooglePlace>();
        predictions.forEach((prediction) {
          var place = GooglePlace.autocompletion(prediction);
          places.add(place);
        });
        completer.complete(places);
      });
    }).catchError((error) {
      print(error.toString());
    });

    return completer.future;
  }

  static Future<List<GooglePlace>> geocodeCoordinates({double lat, double lon}) {

    var completer = new Completer<List<GooglePlace>>();

    var requestUrl = "$googleApiUrl/geocode/json?&latlng=$lat,$lon&language=${IBLocalString.locale}&key=$apiKey";

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.CONTENT_TYPE] = "application/json";

    client.send(request).then((response) {
      response.stream.bytesToString().then((resultStr) {
        var jsonResult = json.decode(resultStr);
        var jsonToParse = jsonResult["results"];
        var places = List<GooglePlace>();
        jsonToParse.forEach((map) {
          var place = GooglePlace.geocode(map);
          places.add(place);
        });
        completer.complete(places);
      });
    }).catchError((error) {
      print(error.toString());
    });

    return completer.future;
  }

  static Future<Map> geocodePlaceId({String placeId}) {

    var completer = new Completer<Map>();

    var requestUrl = "$googleApiUrl/geocode/json?&place_id=$placeId&language=${IBLocalString.locale}&key=$apiKey";

    var client = new Client();
    var request = new Request("POST", Uri.parse(requestUrl));

    request.headers[HttpHeaders.CONTENT_TYPE] = "application/json";

    client.send(request).then((response) {
      response.stream.bytesToString().then((resultStr) {
        var jsonResult = json.decode(resultStr);
        var result = jsonResult["results"].first;
        completer.complete(result);
      });
    }).catchError((error) {
      print(error.toString());
    });

    return completer.future;
  }
}













