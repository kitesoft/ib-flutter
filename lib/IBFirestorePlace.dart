
import 'package:ib/GooglePlace.dart';
import 'package:ib/IBFirestore.dart';

class IBFirestorePlace {

  operator ==(Object o) => o is IBFirestorePlace && id == o.id;
  int get hashCode => id.hashCode;

  // ordered from most specific to less specific
  static const List<String> typesEventsAdd = ["neighborhood", "sublocality", "locality", "administrative_area_level_2", "administrative_area_level_1", "country"];
  static const List<String> typesEventValid = ["establishment", "point_of_interest", "street_address", "street_number", "route", "neighborhood", "sublocality"];

  String id;
  String name;
  String description;
  String address;
  String type;

  int distance;
  int durationAddingDistances;

  double lat;
  double lon;

  List<IBFirestorePlace> places;

  List<String> idsFollowers;


  IBFirestorePlace(this.id, this.name, this.type) {
    places = [];
    idsFollowers = [];
  }


  IBFirestorePlace.firestore(this.id, Map data) {

    name = data[IBFirestore.NAME];
    address = data[IBFirestore.ADDRESS];
    lat = data[IBFirestore.COORDINATE_LAT];
    lon = data[IBFirestore.COORDINATE_LON];
    type = data[IBFirestore.TYPE];

    distance = data[IBFirestore.DISTANCE];
    durationAddingDistances = data[IBFirestore.DURATION_ADDING_DISTANCES];

    idsFollowers = List<String>();
    (data[IBFirestore.IDS_FOLLOWERS] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsFollowers.add(entry.key);
    });

    places = (data[IBFirestore.PLACES] ?? Map()).entries.map<IBFirestorePlace>((entry) => IBFirestorePlace.firestoreEvent(entry.key, entry.value)).toList();
  }


  IBFirestorePlace.firestoreEvent(this.type, Map data) {
    id = data[IBFirestore.ID];
    name = data[IBFirestore.NAME];
    lat = data[IBFirestore.COORDINATE_LAT];
    lon = data[IBFirestore.COORDINATE_LON];
    distance = data[IBFirestore.DISTANCE];
  }

  IBFirestorePlace.googlePlace(GooglePlace gPlace) {

    id = gPlace.id;
    name = gPlace.name ?? (gPlace.addressComponents != null && gPlace.addressComponents.isNotEmpty ? gPlace.addressComponents.first.shortName : null);
    description = gPlace.description;
    address = gPlace.address;

    var types = gPlace.types.where((type) => typesEventValid.contains(type) || typesEventsAdd.contains(type)).toList();
    if (types.isNotEmpty) {
      type = types.first;
    }
    lat = gPlace.lat;
    lon = gPlace.lon;

    idsFollowers = [];
    places = [];
  }

  addGeocode(Map geocode) {
    address = geocode["formatted_address"];
    lat = geocode["geometry"]["location"]["lat"];
    lon = geocode["geometry"]["location"]["lng"];
  }

  bool get isTypeCity {
    return type == "locality" || type == "administrative_area_3";
  }

  bool get isTypeCountry {
    return type == "country";
  }

  bool get didAddDistances {
    return durationAddingDistances != null;
  }

  Map<String, dynamic> get map {
    return {
      IBFirestore.TYPE : type,
      IBFirestore.NAME : name,
      IBFirestore.ADDRESS : address,
      IBFirestore.COORDINATE_LAT : lat,
      IBFirestore.COORDINATE_LON : lon,
      IBFirestore.IDS_FOLLOWERS : idsFollowers.asMap().map((_, id) => MapEntry(id, true)),
      IBFirestore.DURATION_ADDING_DISTANCES : durationAddingDistances,
    };
  }

  Map<String, dynamic> get mapPayloadEvent {
    return {
      IBFirestore.ID : id,
      IBFirestore.NAME : name,
    };
  }

  Map<String, dynamic> get mapPayloadPlace {
    return {
      IBFirestore.ID : id,
      IBFirestore.TYPE : type,
      IBFirestore.DISTANCE : distance
    };
  }

  Map<String, dynamic> get mapPayloadUser {
    return {
      IBFirestore.NAME : name,
      IBFirestore.TYPE : type,
    };
  }
}