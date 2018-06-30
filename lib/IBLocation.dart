
import 'dart:async';

import 'package:location/location.dart';

import 'package:ib/GoogleAPI.dart';

import 'package:ib/IBFirestorePlace.dart';

class IBLocation {

  static var location = new Location();
  static Map info;
  static var isLocationDisabled = false;

  static double get latitude {
    return info["latitude"];
  }

  static double get longitude {
    return info["longitude"];
  }

  static IBFirestorePlace placeCity;
  static IBFirestorePlace placeCountry;

  static Future<Map> getLocationInfo() async {
    var completer = new Completer<Map>();
    try {
      IBLocation.info = await location.getLocation;
    } on Exception {
      isLocationDisabled = true;
    }
    completer.complete(IBLocation.info);
    return completer.future;
  }

  static Future<List<IBFirestorePlace>> getPlaces() async {

    var completer = new Completer<List<IBFirestorePlace>>();
    var gPlaces = await GoogleAPI.geocodeCoordinates(lat: latitude, lon: longitude);
    var places = gPlaces.map((gPlace) => IBFirestorePlace.googlePlace(gPlace)).toList();

    var placesCities = places.where((place) => place.isTypeCity);
    if (placesCities.isNotEmpty) {
      placeCity = placesCities.first;
    }

    var placesCountry = places.where((place) => place.isTypeCountry);
    if (placesCountry.isNotEmpty) {
      placeCountry = placesCountry.first;
    }

    completer.complete(places);
    return completer.future;
  }
}









