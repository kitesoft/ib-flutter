
import 'package:ib/IBDateTime.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestorePlace.dart';

class IBFirestoreEvent {

  operator ==(Object o) => o is IBFirestoreEvent && id == o.id;
  int get hashCode => id.hashCode;

  String id;
  String name;
  String description;

  double countFollowersDouble;

  String idCreator;
  String idGroup;
  List<String> idsFollowers;

  IBFirestorePlace placePayload;
  List<IBFirestorePlace> places;

  double timestampEnd;
  double timestampStart;

  IBFirestoreEvent(this.name, this.description, this.idCreator, this.idGroup, this.places, this.timestampStart, this.timestampEnd) {
    idsFollowers = [];
  }

  IBFirestoreEvent.firestore(this.id, Map data) {

    name = data[IBFirestore.NAME];
    description = data[IBFirestore.DESCRIPTION];

    countFollowersDouble = data[IBFirestore.COUNT_FOLLOWERS];

    idCreator = (data[IBFirestore.ID_CREATOR] ?? Map()).entries.first.key;

    if (data[IBFirestore.ID_GROUP] != null) {
      idGroup = (data[IBFirestore.ID_GROUP] ?? Map()).entries.first.key;
    }

    idsFollowers = List<String>();
    (data[IBFirestore.IDS_FOLLOWERS] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsFollowers.add(entry.key);
    });

    places = (data[IBFirestore.PLACES] ?? Map()).entries.map<IBFirestorePlace>((entry) => IBFirestorePlace.firestoreEvent(entry.key, entry.value)).toList();

    var allTypes = IBFirestorePlace.typesEventValid + IBFirestorePlace.typesEventsAdd;
    places.sort((place1, place2) => allTypes.indexOf(place1.type).compareTo(allTypes.indexOf(place2.type)));
    placePayload = places.first;

    timestampEnd = data[IBFirestore.TIMESTAMP_END];
    timestampStart = data[IBFirestore.TIMESTAMP_START];
  }

  int get countFollowers {
    return idsFollowers.length;
  }

  double get countFollowersDoubleFresh {
    int divisor;
    var hashCodeId = id.hashCode;
    if (hashCodeId < 10) {
      divisor = 10;
    }
    else if (hashCodeId < 100) {
      divisor = 100;
    }
    else if (hashCodeId < 1000) {
      divisor = 1000;
    }
    else if (hashCodeId < 10000) {
      divisor = 10000;
    }
    else if (hashCodeId < 100000) {
      divisor = 100000;
    }
    else if (hashCodeId < 1000000) {
      divisor = 1000000;
    }
    else if (hashCodeId < 10000000) {
      divisor = 10000000;
    }
    else if (hashCodeId < 100000000) {
      divisor = 100000000;
    }
    else if (hashCodeId < 1000000000) {
      divisor = 1000000000;
    }
    else if (hashCodeId < 10000000000) {
      divisor = 10000000000;
    }
    countFollowersDouble = countFollowers + id.hashCode/divisor;
    return countFollowers + id.hashCode/divisor;
  }

  bool get didStart {
    var nowTimestamp = DateTime.now().millisecondsSinceEpoch/1000;
    return (nowTimestamp > timestampStart);
  }

  DateTime get dateStart {
    return IBDateTime.date(timestamp: timestampStart);
  }

  bool get isActive {
    var nowTimestamp = DateTime.now().millisecondsSinceEpoch/1000;
    return (nowTimestamp < timestampEnd);
  }

  bool get isNow {
    var nowTimestamp = DateTime.now().millisecondsSinceEpoch/1000;
    return (nowTimestamp > timestampStart && nowTimestamp < timestampEnd);
  }

  bool get isToday {
    return dateStart.day == DateTime.now().day;
  }

  // NOTE: used for create
  Map<String, dynamic> get map {
    var map = {
      IBFirestore.NAME : name,
      IBFirestore.DESCRIPTION : description,
      IBFirestore.TIMESTAMP_START : timestampStart,
      IBFirestore.TIMESTAMP_END : timestampEnd,
      IBFirestore.ID_CREATOR : [idCreator].asMap().map((_, id) => MapEntry(id, true)),
      IBFirestore.PLACES : places.asMap().map((_, place) => MapEntry(place.type, place.mapPayloadEvent)),
      IBFirestore.COUNT_FOLLOWERS : countFollowersDoubleFresh,
      IBFirestore.IS_ACTIVE : isActive
    };
    if (idGroup != null) {
      map[IBFirestore.ID_GROUP] = [idGroup].asMap().map((_, id) => MapEntry(id, true));
    }
    return map;
  }

  IBFirestorePlace get payloadPlaceCity {
    return places.firstWhere((payload) => payload.isTypeCity);
  }
}