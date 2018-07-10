

import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestorePlace.dart';


class IBFirestoreUser {

  operator ==(Object o) => o is IBFirestoreUser && id == o.id;
  int get hashCode => id.hashCode;

  String id;
  String name;
  String description;
  String codeLanguage;
  String password;
  String token;

  List<String> idsFollowers;
  List<String> idsFollowing;
  List<String> idsGroups;

  List<IBFirestorePlace> placesFollowing;

  IBFirestoreUser(this.name, this.description, this.codeLanguage, this.password, this.token) {
    idsFollowers = [];
    idsFollowing = [];
    idsGroups = [];
    placesFollowing = [];
  }

  IBFirestoreUser.firestore(this.id, Map data) {

    name = data[IBFirestore.NAME];
    description = data[IBFirestore.DESCRIPTION];
    password = data[IBFirestore.PASSWORD];
    token = data[IBFirestore.TOKEN];

    idsFollowers = List<String>();
    (data[IBFirestore.IDS_FOLLOWERS] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsFollowers.add(entry.key);
    });

    idsFollowing = List<String>();
    (data[IBFirestore.IDS_FOLLOWING] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsFollowing.add(entry.key);
    });

    idsGroups = List<String>();
    (data[IBFirestore.IDS_GROUPS] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsGroups.add(entry.key);
    });

    placesFollowing = (data[IBFirestore.PLACES_FOLLOWING] ?? Map()).entries.map<IBFirestorePlace>((entry) => IBFirestorePlace.firestore(entry.key, entry.value)).toList();
  }

  Map<String, dynamic> get map {
    return {
      IBFirestore.NAME : name,
      IBFirestore.DESCRIPTION : description,
      IBFirestore.CODE_LANGUAGE : codeLanguage,
      IBFirestore.PASSWORD : password,
    };
  }

  Map<String, dynamic> get mapPayload {
    return {
      IBFirestore.NAME : name,
      IBFirestore.CODE_LANGUAGE : codeLanguage,
      IBFirestore.TOKEN : token
    };
  }
}