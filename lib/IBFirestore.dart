

import 'dart:async';

import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:great_circle_distance/great_circle_distance.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestoreCacheEvents.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBFirestoreUser.dart';


class IBFirestore {

  // CONST
  static const ADDRESS = "address";
  static const BIRTH_TIMESTAMP = "birth_timestamp";
  static const CITY = "city";
  static const CODE_LANGUAGE = "code_language";
  static const COORDINATE_LAT = "coordinate_lat";
  static const COORDINATE_LON = "coordinate_lon";
  static const COUNT_FOLLOWERS = "count_followers";
  static const DESCRIPTION = "description";
  static const DISTANCE = "distance";
  static const DURATION_ADDING_DISTANCES = "duration_adding_distances";
  static const HAS_DISTANCES = "has_distances";
  static const ID = "id";
  static const ID_CITY = "id_city";
  static const ID_CREATOR = "id_creator";
  static const ID_EVENT = "id_event";
  static const ID_GROUP = "id_group";
  static const IDS_FOLLOWERS = "ids_followers";
  static const IDS_FOLLOWING = "ids_following";
  static const IDS_GROUPS = "ids_groups";
  static const IDS_MEMBERS = "ids_members";
  static const IDS_PLACES = "ids_places";
  static const IS_ACTIVE = "is_active";
  static const MOCK = "mock_";
  static const NAME = "name";
  static const NAMES = "names";
  static const PASSWORD = "pass";
  static const PLACES = "places";
  static const PLACES_FOLLOWING = "places_following";
  static const TIMESTAMP = "timestamp";
  static const TIMESTAMP_END = "timestamp_end";
  static const TIMESTAMP_LAST_MODIFIED_NAME = "timestamp_last_modified_name";
  static const TIMESTAMP_START = "timestamp_start";
  static const TOKEN = "token";
  static const TYPE = "type";

  // COLLECTIONS
  static CollectionReference collectionEvents = Firestore.instance.collection("${debugPrefix}events");
  static CollectionReference collectionEventsGroup = Firestore.instance.collection("${debugPrefix}group_events");
  static CollectionReference collectionGroups = Firestore.instance.collection("groups");
  static CollectionReference collectionPayloads = Firestore.instance.collection("payloads");
  static CollectionReference collectionPlaces = Firestore.instance.collection("places");
  static CollectionReference collectionUsers = Firestore.instance.collection("users");

  // DOCUMENTS
  static DocumentReference documentPayloadsGroups = collectionPayloads.document("${debugPrefix}groups");
  static DocumentReference documentPayloadsUsers = collectionPayloads.document("${debugPrefix}users");

  // UTIL
  static const debugPrefix = bool.fromEnvironment("dart.vm.product") ? "" : MOCK;

  // VARS
  static IBFirestorePlace city;

  static var cachedEvents = List<IBFirestoreCacheEvents>();
  static var cachedGroups = List<IBFirestoreGroup>();
  static var cachedPlaces = List<IBFirestorePlace>();
  static var cachedUsers = List<IBFirestoreUser>();

  static Map groupsPayloads;
  static Map usersPayloads;

  // ADD
  // ...
  // ...
  // ...
  static Future addEvent(IBFirestoreEvent event) async {

    var completer = Completer();

    if (event.id != null) {
      if (event.idGroup == null) {
        await collectionEvents.document(event.id).setData(event.map, merge: true);
      }
      else {
        await collectionEventsGroup.document(event.id).setData(event.map);
      }
    }
    else {
      event.id = collectionEvents.document().documentID;
      if (event.idGroup == null) {
        await collectionEvents.document(event.id).setData(event.map);
      }
      else {
        await collectionEventsGroup.document(event.id).setData(event.map);
      }
    }

    completer.complete();

    return completer.future;
  }


  static Future addGroup(IBFirestoreGroup group) async {

    var completer = Completer();

    if (group.id != null) {
      await collectionGroups.document(group.id).setData(group.map, merge: true);
    }
    else {
      var doc = await collectionGroups.add(group.map);
      group.id = doc.documentID;
      await addGroupPayload(group);
    }

    group.idsMembers.forEach((id) {
      collectionUsers.document(id).setData({
        IDS_GROUPS : {
          group.id : true
        }
      }, merge: true);
    });

    completer.complete();

    return completer.future;
  }


  static Future addGroupIdsMembers(IBFirestoreGroup group, List<String> idsMembers) async {

    var completer = Completer();

    await collectionGroups.document(group.id).setData({
      IDS_MEMBERS : idsMembers.asMap().map((_, id) => MapEntry(id, true)),
    }, merge: true);

    idsMembers.forEach((id) {
      collectionUsers.document(id).setData({
        IDS_GROUPS : {
          group.id : true
        }
      }, merge: true);
    });
    completer.complete();

    return completer.future;
  }


  static Future addGroupPayload(IBFirestoreGroup group) async {

    var completer = Completer();

    groupsPayloads[group.id] = group.mapPayload;

    await documentPayloadsGroups.setData({
      group.id : group.mapPayload
    }, merge: true);

    completer.complete();

    return completer.future;
  }


  static Future<IBFirestorePlace> addPlaceWithDistances(IBFirestorePlace place) async {

    var completer = Completer<IBFirestorePlace>();

    var snapshotQueryCities = await collectionPlaces.where(IBFirestore.TYPE, isEqualTo: "locality").getDocuments();

    var localities = List<IBFirestorePlace>();
    snapshotQueryCities.documents.forEach((snapshot) {
      if (place.id != snapshot.documentID) {
        localities.add(IBFirestorePlace.firestore(snapshot.documentID, snapshot.data));
      }
    });

    var placesPayloads = List<IBFirestorePlace>();
    var timestampStart = DateTime.now().millisecondsSinceEpoch;

    localities.forEach((locality) {

      var distance = new GreatCircleDistance.fromDegrees(
          latitude1: locality.lat,
          longitude1: locality.lon,
          latitude2: place.lat,
          longitude2: place.lon
      ).sphericalLawOfCosinesDistance().toInt();

      place.distance = distance;
      locality.distance = distance;

      collectionPlaces.document(locality.id).setData({
        PLACES : {
          place.id : place.mapPayloadPlace
        }
      }, merge: true);

      placesPayloads.add(locality);
    });

    var timestampEnd = DateTime.now().millisecondsSinceEpoch;

    place.durationAddingDistances = timestampEnd - timestampStart;
    place.places = placesPayloads;

    await collectionPlaces.document(place.id).setData(place.map, merge: true);

    completer.complete(place);

    return completer.future;
  }


  static Future addUserApp() async {

    var completer = Completer();

    if (IBUserApp.current.id != null) {
      await collectionUsers.document(IBUserApp.current.id).setData(IBUserApp.current.map, merge: true);
    }
    else {
      var doc = await collectionUsers.add(IBUserApp.current.map);
      IBUserApp.current.id = doc.documentID;
      await addUserAppPayload();
    }

    completer.complete();

    return completer.future;
  }


  static Future addUserAppPayload() async {

    var completer = Completer();

    groupsPayloads[IBUserApp.current.id] = IBUserApp.current.mapPayload;

    await documentPayloadsUsers.setData({
      IBUserApp.current.id : IBUserApp.current.mapPayload,
    }, merge: true);

    completer.complete();

    return completer.future;
  }



  // FOLLOW
  // ...
  // ...
  // ...
  static Future followEvent(IBFirestoreEvent event, {bool follow = true}) async {

    var completer = Completer();

    if (event.idGroup == null) {
      await collectionEvents.document(event.id).setData({
        IDS_FOLLOWERS : {
          IBUserApp.current.id : follow
        },
        COUNT_FOLLOWERS : event.countFollowersDoubleFresh
      }, merge: true);
    }
    else {
      await collectionEventsGroup.document(event.id).setData({
        IDS_FOLLOWERS : {
          IBUserApp.current.id : follow
        },
      }, merge: true);
    }

    completer.complete(event);

    return completer.future;
  }


  static Future followPlace(IBFirestorePlace place, {bool follow = true}) async {

    var completer = Completer();

    await collectionPlaces.document(place.id).setData({
      IDS_FOLLOWERS : {
        IBUserApp.current.id : follow
      },
    }, merge: true);

    await collectionUsers.document(IBUserApp.current.id).setData({
      PLACES_FOLLOWING : {
        place.id : place.mapPayloadUser
      },
    }, merge: true);

    completer.complete(place);

    return completer.future;
  }


  static Future followUser(IBFirestoreUser user, {bool follow = true}) async {

    var completer = Completer();

    await collectionUsers.document(user.id).setData({
      IDS_FOLLOWERS : {
        IBUserApp.current.id : follow
      }
    }, merge: true);

    await collectionUsers.document(IBUserApp.current.id).setData({
      IDS_FOLLOWING : {
        user.id : follow
      }
    }, merge: true);

    completer.complete();

    return completer.future;
  }



  // GET
  // ...
  // ...
  // ...
  static Future<List<IBFirestoreEvent>> getEvents({String idPlace, String idUserCreator, String idUserFollower, bool isActive, String typePlace}) async {

    var completer = Completer<List<IBFirestoreEvent>>();

    var cached = cachedEvents.where((q) => q.idPlace == idPlace && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && (q.isActive == isActive || q.isActive == null || isActive == null) && q.isCollectionGroups == false).toList();

    if (cached.isNotEmpty) {
      var events = List<IBFirestoreEvent>();
      events.addAll(cached.first.events);
      if (cached.first.isActive != isActive) {
        if (cached.first.isActive == null) {
          events.removeWhere((event) => event.isActive != isActive);
        }
        else if (isActive == null) {
          var eventsMissing = List<IBFirestoreEvent>();
          if (cached.length > 1 && cached[1].isActive == !cached.first.isActive) {
            eventsMissing = cached[1].events;
          }
          else {
            eventsMissing = await getEvents(idPlace: idPlace, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: !cached.first.isActive);
          }
          events.addAll(eventsMissing);
        }
      }
      completer.complete(events);
    }
    else {

      Query query = collectionEvents;

      if (idPlace != null && typePlace != null) {
        query = query.where("$PLACES.$typePlace.$ID", isEqualTo: idPlace);
      }
      if (idUserCreator != null) {
        query = query.where("$ID_CREATOR.$idUserCreator", isEqualTo: true);
      }
      if (idUserFollower != null) {
        query = query.where("$IDS_FOLLOWERS.$idUserFollower", isEqualTo: true);
      }
      if (isActive != null) {
        query = query.where(IS_ACTIVE, isEqualTo: isActive);
      }

      var queryDocuments = await query.getDocuments();

      var events = List<IBFirestoreEvent>();
      queryDocuments.documents.forEach((snapshot) {
        var event = IBFirestoreEvent.firestore(snapshot.documentID, snapshot.data);
        if (isActive != null && isActive && !event.isActive) {
          setEventInactive(event);
        }
        events.add(event);
      });

      cachedEvents.add(IBFirestoreCacheEvents(events: events, idPlace: idPlace, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: isActive, isCollectionGroups: false,  typePlace: typePlace));

      completer.complete(events);
    }

    return completer.future;
  }


  static Future<List<IBFirestoreEvent>> getEventsGroup({String idGroup, String idUserCreator, String idUserFollower, bool isActive}) async {

    var completer = Completer<List<IBFirestoreEvent>>();

    var cached = cachedEvents.where((q) => q.idGroup == idGroup && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && (q.isActive == isActive || q.isActive == null || isActive == null) && q.isCollectionGroups == true).toList();

    if (cached.isNotEmpty) {
      var events = cached.first.events;
      if (cached.first.isActive != isActive) {
        if (cached.first.isActive == null) {
          events.removeWhere((event) => event.isActive != isActive);
        }
        else if (isActive == null) {
          var eventsMissing = List<IBFirestoreEvent>();
          if (cached.length > 1 && cached[1].isActive == !cached.first.isActive) {
            eventsMissing = cached[1].events;
          }
          else {
            eventsMissing = await getEventsGroup(idGroup: idGroup, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: !cached.first.isActive);
          }
          events.addAll(eventsMissing);
        }
      }
      completer.complete(events);
    }

    else {

      Query query = collectionEventsGroup;

      if (idGroup != null) {
        query = query.where("$ID_GROUP.$idGroup", isEqualTo: true);
      }
      if (isActive != null) {
        query = query.where(IS_ACTIVE, isEqualTo: isActive);
      }
      if (idUserCreator != null) {
        query = query.where("$ID_CREATOR.$idUserCreator", isEqualTo: true);
      }
      if (idUserFollower != null) {
        query = query.where("$IDS_FOLLOWERS.$idUserFollower", isEqualTo: true);
      }

      var queryDocuments = await query.getDocuments();

      var events = List<IBFirestoreEvent>();
      queryDocuments.documents.forEach((snapshot) {
        var event = IBFirestoreEvent.firestore(snapshot.documentID, snapshot.data);
        if (isActive != null && isActive && !event.isActive) {
          setEventInactive(event);
        }
        events.add(event);
      });

      cachedEvents.add(IBFirestoreCacheEvents(events: events, idGroup: idGroup, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isCollectionGroups: true, isActive: isActive));

      completer.complete(events);
    }

    return completer.future;
  }

  static Future<List<IBFirestoreEvent>> getEventsIndexed({String idPlace, String typePlace, String idUserCreator, String idUserFollower, bool isActive, double countFollowersStartAfter, double countFollowersEndAt, int sizeLimit}) async {

    var completer = Completer<List<IBFirestoreEvent>>();

    var cached = cachedEvents.where((q) => q.idPlace == idPlace && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && (q.isActive == isActive || q.isActive == null || isActive == null) && q.isCollectionGroups == false).toList();

    if (cached.isNotEmpty && (countFollowersStartAfter == null || countFollowersStartAfter != cached.first.events.last.countFollowersDouble)) {
      var events = List<IBFirestoreEvent>();
      events.addAll(cached.first.events);
      if (countFollowersStartAfter != null) {
        events.removeWhere((event) => event.countFollowers >= countFollowersStartAfter);
      }
      if (countFollowersEndAt != null) {
        events.removeWhere((event) => event.countFollowers < countFollowersEndAt);
      }
      if (sizeLimit != null && events.length < sizeLimit && !cached.first.didLoadIndexed) {
        var eventsAdd = await getEventsIndexed(idPlace: idPlace, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: isActive, typePlace: typePlace, countFollowersStartAfter: events.last.countFollowersDouble, countFollowersEndAt: countFollowersEndAt, sizeLimit: sizeLimit - cached.first.events.length);
        cached.first.events.addAll(eventsAdd);
      }
      completer.complete(events);
    }
    else {

      Query query = collectionEvents;

      if (idPlace != null && typePlace != null) {
        query = query.where("$PLACES.$typePlace.$ID", isEqualTo: idPlace);
      }
      if (idUserCreator != null) {
        query = query.where("$ID_CREATOR.$idUserCreator", isEqualTo: true);
      }
      if (idUserFollower != null) {
        query = query.where("$IDS_FOLLOWERS.$idUserFollower", isEqualTo: true);
      }
      if (countFollowersStartAfter != null || countFollowersEndAt != null) {
        query = query.orderBy(COUNT_FOLLOWERS, descending: true);
      }
      if (countFollowersStartAfter != null) {
        query = query.startAfter([countFollowersStartAfter]);
      }
      if (countFollowersEndAt != null) {
        query = query.endAt([countFollowersEndAt]);
      }
      if (isActive != null) {
        query = query.where(IS_ACTIVE, isEqualTo: isActive);
      }
      if (sizeLimit != null) {
        query = query.limit(sizeLimit);
      }

      var queryDocuments = await query.getDocuments();

      var events = List<IBFirestoreEvent>();
      queryDocuments.documents.forEach((snapshot) {
        var event = IBFirestoreEvent.firestore(snapshot.documentID, snapshot.data);
        if (isActive != null && isActive && !event.isActive) {
          setEventInactive(event);
        }
        events.add(event);
      });

      if (cached.isNotEmpty) {
        cached.first.events.addAll(events);
        cached.first.didLoadIndexed = events.length < sizeLimit;
      }
      else {
        cachedEvents.add(IBFirestoreCacheEvents(didLoadIndexed: events.length < sizeLimit, events: events, idPlace: idPlace, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: isActive, isCollectionGroups: false, typePlace: typePlace));
      }

      completer.complete(events);
    }

    return completer.future;
  }


  static Future<IBFirestoreGroup> getGroup(String id) async {

    var completer = Completer<IBFirestoreGroup>();

    var cached = cachedGroups.where((group) => group.id == id);

    if (cached.isNotEmpty) {
      completer.complete(cached.first);
    }
    else {
      var snapshot = await collectionGroups.document(id).get();
      if (snapshot != null) {
        var group = IBFirestoreGroup.firestore(snapshot.documentID, snapshot.data);
        cachedGroups.add(group);
        completer.complete(group);
      }
      else {
        completer.complete(null);
      }
    }

    return completer.future;
  }


  static Future<Map> getGroupsPayloads() async {

    var completer = Completer<Map>();

    if (groupsPayloads != null) {
      completer.complete(groupsPayloads);
    }
    else {
      var snapshot = await documentPayloadsGroups.get();
      groupsPayloads = snapshot.data ?? Map();
      completer.complete(snapshot.data);
    }

    return completer.future;
  }


  static Future<Map> getUsersPayloads() async {

    var completer = Completer<Map>();

    if (usersPayloads != null) {
      completer.complete(usersPayloads);
    }
    else {
      var snapshot = await documentPayloadsUsers.get();
      usersPayloads = snapshot.data ?? Map();
      completer.complete(snapshot.data);
    }

    return completer.future;
  }


  static Future<IBFirestorePlace> getPlace(String id) async {

    var completer = Completer<IBFirestorePlace>();

    var cached = cachedPlaces.where((place) => place.id == id);

    if (cached.isNotEmpty) {
      completer.complete(cached.first);
    }
    else {
      var snapshot = await collectionPlaces.document(id).get();
      if (snapshot.data != null) {
        var place = IBFirestorePlace.firestore(snapshot.documentID, snapshot.data);
        cachedPlaces.add(place);
        completer.complete(place);
      }
      else {
        completer.complete(null);
      }
    }

    return completer.future;
  }


  static Future<IBFirestoreUser> getUser(String id) async {

    var completer = Completer<IBFirestoreUser>();

    var cached = cachedUsers.where((user) => user.id == id);

    if (cached.isNotEmpty) {
      completer.complete(cached.first);
    }
    else {
      var snapshot = await collectionUsers.document(id).get();
      if (snapshot.data != null) {
        var user = IBFirestoreUser.firestore(snapshot.documentID, snapshot.data);
        cachedUsers.add(user);
        completer.complete(user);
      }
      else {
        completer.complete(null);
      }
    }

    return completer.future;
  }


  static Future<IBFirestoreUser> getUserLogin(String name, String password) async {

    var completer = Completer<IBFirestoreUser>();

    Query query = collectionUsers;
    query = query.where(NAME, isEqualTo: name);
    query = query.where(PASSWORD, isEqualTo: password);

    var snapshot = await query.getDocuments();

    if (snapshot.documents.length == 1) {
      var user = IBFirestoreUser.firestore(snapshot.documents.first.documentID, snapshot.documents.first.data);
      completer.complete(user);
    }
    else {
      completer.complete();
    }

    return completer.future;
  }



  // LISTEN
  // ...
  // ...
  // ...
  static Stream<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>> listenEvents({String idPlace, String idUserCreator, String idUserFollower, bool isActive, String typePlace}) {

    var streamController = StreamController<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>>();

    Query query = collectionEvents;

    if (idPlace != null && typePlace != null) {
      query = query.where("$PLACES.$typePlace.$ID", isEqualTo: idPlace);
    }
    if (idUserCreator != null) {
      query = query.where("$ID_CREATOR.$idUserCreator", isEqualTo: true);
    }
    if (idUserFollower != null) {
      query = query.where("$IDS_FOLLOWERS.$idUserFollower", isEqualTo: true);
    }
    if (isActive != null) {
      query = query.where(IS_ACTIVE, isEqualTo: isActive);
    }

    query.snapshots().listen((snapshot) {

      var eventsAdded = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.added).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();
      var eventsModified = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.modified).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();

      var cached = cachedEvents.where((q) => q.idPlace == idPlace && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && q.isActive == isActive).toList();

      if (cached.isNotEmpty) {
        cached.first.events.addAll(eventsAdded);
        eventsModified.forEach((event) {
          var idx = cached.first.events.indexOf(event);
          cached.first.events[idx] = event;
        });
      }
      else {
        cachedEvents.add(IBFirestoreCacheEvents(events: eventsAdded + eventsModified, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: true));
      }

      streamController.add(Tuple2(eventsAdded, eventsModified));

    });

    return streamController.stream;
  }


  static Stream<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>> listenEventsGroup({String idGroup, String idUserCreator, String idUserFollower, bool isActive}) {

    var streamController = StreamController<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>>();

    Query query = collectionEventsGroup;

    if (idGroup != null) {
      query = query.where("$ID_GROUP.$idGroup", isEqualTo: true);
    }
    if (isActive != null) {
      query = query.where(IS_ACTIVE, isEqualTo: isActive);
    }
    if (idUserCreator != null) {
      query = query.where("$ID_CREATOR.$idUserCreator", isEqualTo: true);
    }
    if (idUserFollower != null) {
      query = query.where("$IDS_FOLLOWERS.$idUserFollower", isEqualTo: true);
    }

    query.snapshots().listen((snapshot) {

      var eventsAdded = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.added).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();
      var eventsModified = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.modified).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();

      var cached = cachedEvents.where((q) => q.idGroup == idGroup && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && q.isActive == isActive).toList();

      if (cached.isNotEmpty) {
        cached.first.events.addAll(eventsAdded);
        eventsModified.forEach((event) {
          var idx = cached.first.events.indexOf(event);
          cached.first.events[idx] = event;
        });
      }
      else {
        cachedEvents.add(IBFirestoreCacheEvents(events: eventsAdded + eventsModified, idGroup: idGroup, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: true));
      }

      streamController.add(Tuple2(eventsAdded, eventsModified));

    });

    return streamController.stream;
  }


  static Stream<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>> listenEventsIndexed({String idPlace, String typePlace, String idUserCreator, String idUserFollower, bool isActive, double countFollowersStartAfter, double countFollowersEndAt, int sizeLimit = 6}) {

    var streamController = StreamController<Tuple2<List<IBFirestoreEvent>, List<IBFirestoreEvent>>>();

    Query query = collectionEvents;
    query = query.where("$PLACES.$typePlace.$ID", isEqualTo: idPlace);
    query = query.where(IS_ACTIVE, isEqualTo: true);
    query = query.limit(sizeLimit);

    if (countFollowersStartAfter != null || countFollowersEndAt != null) {
      query = query.orderBy(COUNT_FOLLOWERS, descending: true);
    }
    if (countFollowersStartAfter != null) {
      query = query.startAfter([countFollowersStartAfter]);
    }
    if (countFollowersEndAt != null) {
      query = query.endAt([countFollowersEndAt]);
    }

    query.snapshots().listen((snapshot) {

      var eventsAdded = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.added).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();
      var eventsModified = snapshot.documentChanges.where((documentChange) => documentChange.type == DocumentChangeType.modified).map<IBFirestoreEvent>((documentChange) => IBFirestoreEvent.firestore(documentChange.document.documentID, documentChange.document.data)).toList();

      var cached = cachedEvents.where((q) => q.idPlace == idPlace && q.idUserCreator == idUserCreator && q.idUserFollower == idUserFollower && q.isActive == isActive).toList();

      if (cached.isNotEmpty) {
        (eventsAdded + eventsModified).forEach((event) {
          var idx = cached.first.events.indexOf(event);
          if (idx == -1) {
            cached.first.events.add(event);
          }
          else {
            cached.first.events[idx] = event;
          }
        });
        cached.first.events.sort((event1, event2) => event2.countFollowersDouble.compareTo(event1.countFollowersDouble));
      }
      else {
        cachedEvents.add(IBFirestoreCacheEvents(events: eventsAdded + eventsModified, idPlace: idPlace, typePlace: typePlace, idUserCreator: idUserCreator, idUserFollower: idUserFollower, isActive: isActive));
      }

      streamController.add(Tuple2(eventsAdded, eventsModified));

    });

    return streamController.stream;
  }



  // SET
  // ...
  // ...
  // ...
  static Future setEventInactive(IBFirestoreEvent event) async {

    var completer = Completer<List<String>>();

    if (event.idGroup == null) {
      await collectionEvents.document(event.id).setData({
        IS_ACTIVE : false
      }, merge: true);
    }
    else {
      await collectionEventsGroup.document(event.id).setData({
        IS_ACTIVE : false
      }, merge: true);
    }

    completer.complete();

    return completer.future;
  }


// TEMP
// ...
// ...
//  static tempEventsCountFollowers(List<IBFirestoreEvent> events) {
//    events.forEach((event) {
//      collectionEvents.document(event.id).setData({
//        COUNT_FOLLOWERS : event.countFollowersDouble
//      });
//    });
//  }
}



