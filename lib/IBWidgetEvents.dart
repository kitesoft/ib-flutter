

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDefaults.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreCacheEvents.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocation.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetEvent.dart';
import 'package:ib/IBWidgetEventCreate.dart';
import 'package:ib/IBWidgetUser.dart';
import 'package:ib/IBWidgetUserCreate.dart';
import 'package:ib/IBWidgetUserIcon.dart';


class IBWidgetEvents extends StatefulWidget {

  IBWidgetEvents({Key key}) : super(key: key);

  @override
  IBStateWidgetEvents createState() {
    return IBStateWidgetEvents();
  }
}


class IBStateWidgetEvents extends State<IBWidgetEvents> {

  static const lengthLoadEvents = 5;

  static const millisecondsAnimationScroll = 250;

  static const sizeContainerBottom = 100.0;
  static const sizeContainerCountNew = 45.0;
  static const sizeActionIcon = 28.0;
  static const sizeActionUserApp = 35.0;
  static const sizeCountEvents = 16.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  var countEventsNew = 0;

  var events = List<IBFirestoreEvent>();
  var eventsPageNew = List<IBFirestoreEvent>();

  var eventsUserAppCreated = List<IBFirestoreEvent>();
  var eventsUserAppFollowing = List<IBFirestoreEvent>();

  var indexQuery = 0;

  var isDoneLoading = false;
  var isLoading = false;

  var isTappedActionAdd = false;
  var isTappedActionUser = false;

  var queries = List<IBFirestoreCacheEvents>();

  var scrollController = ScrollController();


  @override
  void initState() {

    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    IBLocalString.context = context;

    IBMessaging.instance.configure(
        onLaunch: (message) {
          print(" onLaunch called $message");
        },
        onResume: (message) {
          print(" onResume called $message");
        },
        onMessage: (message) {
          print(" onMessage called $message");
        }
    );

    FirebaseAuth.instance.signInAnonymously();

    setupAsync();

    scrollController.addListener(() async {
      if (scrollController.offset == scrollController.position.maxScrollExtent && !isDoneLoading && !isLoading) {
        loadEvents();
      }
      if (scrollController.offset == 0) {
        setState(() {
          countEventsNew = 0;
        });
      }
    });
  }


  setupAsync() async {

//    await IBDefaults.setIdUser("-LFMRnR60Q6sLHJWoqo7");

    var defaultIdUser = await IBDefaults.getIdUser();

    if (defaultIdUser != null) {
      var user = await IBFirestore.getUser(defaultIdUser);
      setState(() {
        IBUserApp.current = user;
      });
    }

    await IBFirestore.getGroupsPayloads();
    await IBFirestore.getUsersPayloads();

    var location = await IBLocation.getLocationInfo();

    if (IBUserApp.current != null) {

      var token = await IBMessaging.getToken();
      var defaultToken = await IBDefaults.getToken();

      if (token != defaultToken) {
        IBDefaults.setToken(token);
        IBUserApp.current.token = token;
        IBFirestore.addUserAppPayload();
      }

      eventsUserAppCreated.addAll(await IBFirestore.getEvents(idUserCreator: IBUserApp.current.id, isActive: true));
      eventsUserAppCreated.addAll(await IBFirestore.getEventsGroup(idUserCreator: IBUserApp.current.id, isActive: true));

      eventsUserAppFollowing.addAll(await IBFirestore.getEvents(idUserFollower: IBUserApp.current.id, isActive: true));
      eventsUserAppFollowing.addAll(await IBFirestore.getEventsGroup(idUserFollower: IBUserApp.current.id, isActive: true));

      setState(() {
        this.eventsUserAppCreated = eventsUserAppCreated;
        this.eventsUserAppFollowing = eventsUserAppFollowing;
      });

      queries.addAll(IBUserApp.current.idsFollowing.map<IBFirestoreCacheEvents>((userId) => IBFirestoreCacheEvents(idUserCreator: userId, isActive: true)));
      queries.addAll(IBUserApp.current.idsFollowing.map<IBFirestoreCacheEvents>((userId) => IBFirestoreCacheEvents(idUserFollower: userId, isActive: true)));
      queries.addAll(IBUserApp.current.idsGroups.map<IBFirestoreCacheEvents>((userId) => IBFirestoreCacheEvents(idGroup: userId, isActive: true)));
    }

    if (location != null) {

      await IBLocation.getPlaces();

      if (IBLocation.placeCity != null) {

        var place = await IBFirestore.getPlace(IBLocation.placeCity.id);

        if (place == null) {
          if (IBUserApp.current != null) {
            IBLocation.placeCity.idsFollowers.add(IBUserApp.current.id);
            IBUserApp.current.placesFollowing.add(IBLocation.placeCity);
          }
          IBLocation.placeCity = await IBFirestore.addPlaceWithDistances(IBLocation.placeCity);
        }
        else {
          IBLocation.placeCity = place;
          if (IBUserApp.current != null) {
            if (!IBLocation.placeCity.idsFollowers.contains(IBUserApp.current.id)) {
              IBFirestore.followPlace(IBLocation.placeCity);
            }
          }
        }
        
        queries.add(IBFirestoreCacheEvents(idPlace: IBLocation.placeCity.id, typePlace: IBLocation.placeCity.type, isActive: true));
        queries.add(IBFirestoreCacheEvents(idPlace: IBLocation.placeCity.id, typePlace: IBLocation.placeCity.type, isActive: true));
      }
    }

    if (IBUserApp.current != null) {
      queries.addAll(IBUserApp.current.placesFollowing.where((placePayload) => placePayload.id != IBLocation.placeCity.id).map((placePayload) => IBFirestoreCacheEvents(idPlace: placePayload.id, typePlace: placePayload.type, isActive: true)));
      queries.addAll(IBUserApp.current.placesFollowing.where((placePayload) => placePayload.id != IBLocation.placeCity.id).map((placePayload) => IBFirestoreCacheEvents(idPlace: placePayload.id, typePlace: placePayload.type, isActive: true)));
    }

    if (location != null) {
      var excludePayloads = List<IBFirestorePlace>();
      if (IBUserApp.current != null) {
        excludePayloads = IBUserApp.current.placesFollowing;
      }
      queries.addAll(IBLocation.placeCity.places.where((placePayload) => !excludePayloads.contains(placePayload)).map((placePayload) => IBFirestoreCacheEvents(idPlace: placePayload.id, typePlace: placePayload.type, isActive: true)));
      queries.addAll(IBLocation.placeCity.places.where((placePayload) => !excludePayloads.contains(placePayload)).map((placePayload) => IBFirestoreCacheEvents(idPlace: placePayload.id, typePlace: placePayload.type, isActive: true)));
    }

    if (location == null) {
      queries.add(IBFirestoreCacheEvents(isActive: true));
      queries.add(IBFirestoreCacheEvents(isActive: true));
    }

    loadEvents();
  }


  loadEvents() async {

    isLoading = true;

    var query = queries[indexQuery];

    if (query.idUserCreator != null) {
      IBFirestore.listenEvents(idUserCreator: query.idUserCreator, isActive: true).listen((tuple) {
        var isLoadFirst = indexQuery < queries.length && queries[indexQuery].idUserCreator == query.idUserCreator;
        var eventsAdded = tuple.item1;
        if (isLoadFirst) {
          indexQuery += 1;
          eventsPageNew.addAll(eventsAdded);
          if (eventsAdded.length < lengthLoadEvents && indexQuery != queries.length) {
            loadEvents();
          }
          else {
            setState(() {
              this.events.addAll(eventsPageNew.sublist(0, min(eventsPageNew.length, lengthLoadEvents)));
            });
            eventsPageNew.removeRange(0, min(eventsPageNew.length, lengthLoadEvents));
            isLoading = false;
          }
          if (indexQuery  == queries.length) {
            setState(() {
              isDoneLoading = true;
            });
          }
        }
        else {
          var eventsModified = tuple.item2;
          setState(() {
            eventsPageNew.addAll(eventsAdded);
            eventsModified.forEach((eventModified) {
              var indexOfModified = this.events.indexOf(eventModified);
              this.events[indexOfModified] = eventModified;
            });
          });
        }
      });
    }
    else if (query.idUserFollower != null) {
      var events = await IBFirestore.getEvents(idUserFollower: query.idUserFollower, isActive: true);
      indexQuery += 1;
      var eventsOriginal = events.where((event) => !this.events.contains(event)).where((event) => !eventsUserAppCreated.contains(event));
      eventsPageNew.addAll(eventsOriginal);
      if (eventsPageNew.length < lengthLoadEvents && indexQuery != queries.length) {
        loadEvents();
      }
      else {
        setState(() {
          this.events.addAll(eventsPageNew.sublist(0, min(eventsPageNew.length, lengthLoadEvents)));
        });
        eventsPageNew.removeRange(0, min(eventsPageNew.length, lengthLoadEvents));
        isLoading = false;
      }
      if (indexQuery == queries.length) {
        setState(() {
          isDoneLoading = true;
        });
      }
    }
    else if (query.idGroup != null) {
      IBFirestore.listenEventsGroup(idGroup: query.idGroup, isActive: true).listen((tuple) {
        var isLoadFirst = indexQuery < queries.length && queries[indexQuery].idGroup == query.idGroup;
        var eventsAddedOriginal = tuple.item1.where((event) => !this.events.contains(event)).where((event) => !eventsUserAppCreated.contains(event));
        if (isLoadFirst) {
          indexQuery += 1;
          eventsPageNew.addAll(eventsAddedOriginal);
          if (eventsAddedOriginal.length < lengthLoadEvents && indexQuery != queries.length) {
            loadEvents();
          }
          else {
            setState(() {
              this.events.addAll(eventsPageNew.sublist(0, min(eventsPageNew.length, lengthLoadEvents)));
            });
            eventsPageNew.removeRange(0, min(eventsPageNew.length, lengthLoadEvents));
            isLoading = false;
          }
          if (indexQuery == queries.length) {
            setState(() {
              isDoneLoading = true;
            });
          }
        }
        else {
          var eventsModified = tuple.item2;
          setState(() {
            eventsPageNew.addAll(eventsAddedOriginal);
            eventsModified.forEach((eventModified) {
              var indexOfModified = this.events.indexOf(eventModified);
              this.events[indexOfModified] = eventModified;
            });
          });
        }
      });
    }
    else if (query.idPlace != null && (indexQuery == 0 || queries[indexQuery - 1].idPlace != query.idPlace)) {
      var countFollowersStartAfter = query.events != null && query.events.isNotEmpty ? query.events.last.countFollowersDouble : null;
      var events = await IBFirestore.getEventsIndexed(idPlace: query.idPlace, typePlace: query.typePlace, countFollowersStartAfter: countFollowersStartAfter, countFollowersEndAt: 1.0, sizeLimit: lengthLoadEvents, isActive: true);
      if (events.length < lengthLoadEvents) {
        indexQuery += 1;
      }
      var eventsOriginal = events.where((event) => !this.events.contains(event)).where((event) => !eventsUserAppCreated.contains(event));
      if (query.events == null) {
        query.events = events;
      }
      else {
        query.events.addAll(events);
      }
      eventsPageNew.addAll(eventsOriginal);
      if (eventsPageNew.length < lengthLoadEvents && indexQuery != queries.length) {
        loadEvents();
      }
      else {
        setState(() {
          this.events.addAll(eventsPageNew.sublist(0, min(eventsPageNew.length, lengthLoadEvents)));
        });
        eventsPageNew.removeRange(0, min(eventsPageNew.length, lengthLoadEvents));
        isLoading = false;
      }
      if (indexQuery == queries.length) {
        setState(() {
          isDoneLoading = true;
        });
      }
    }
    else if (query.idPlace != null && (indexQuery > 0 && queries[indexQuery - 1].idPlace == query.idPlace)) {
      var countFollowersStartAfter = query.events != null && query.events.isNotEmpty ? query.events.last.countFollowersDouble : 1.0;
      IBFirestore.listenEventsIndexed(idPlace: query.idPlace, typePlace: query.typePlace, countFollowersStartAfter: countFollowersStartAfter, isActive: true, sizeLimit: lengthLoadEvents).listen((tuple) {
        var isLoadFirst = indexQuery < queries.length && queries[indexQuery].idPlace == query.idPlace;
        var eventsAdded = tuple.item1;
        var eventsAddedOriginal = eventsAdded.where((event) => !this.events.contains(event)).where((event) => !eventsUserAppCreated.contains(event));
        if (IBUserApp.current != null) {
          eventsAddedOriginal = eventsAddedOriginal.where((event) => !IBUserApp.current.idsFollowing.contains(event.idCreator));
        }
        if (isLoadFirst) {
          if (eventsAdded.length < lengthLoadEvents) {
            indexQuery += 1;
          }
          if (query.events == null) {
            query.events = eventsAdded;
          }
          else {
            query.events.addAll(eventsAdded);
          }
          eventsPageNew.addAll(eventsAddedOriginal);
          if (eventsPageNew.length < lengthLoadEvents && indexQuery != queries.length) {
            loadEvents();
          }
          else {
            setState(() {
              this.events.addAll(eventsPageNew.sublist(0, min(eventsPageNew.length, lengthLoadEvents)));
            });
            eventsPageNew.removeRange(0, min(eventsPageNew.length, lengthLoadEvents));
            isLoading = false;
          }
          if (indexQuery == queries.length) {
            setState(() {
              isDoneLoading = true;
            });
          }
        }
        else {
          var eventsModified = tuple.item2;
          setState(() {
            eventsPageNew.addAll(eventsAddedOriginal);
            eventsModified.forEach((eventModified) {
              var indexOfModified = this.events.indexOf(eventModified);
              this.events[indexOfModified] = eventModified;
            });
          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            child: Container(
              child: Icon(
                Icons.library_add,
                color: isTappedActionAdd ? IBColors.actionTappedDown : Colors.white,
                size: sizeActionIcon,
              ),
              padding: EdgeInsets.only(
                  right: spacingHorizontal
              ),
            ),
            onTapCancel: () {
              setState(() {
                isTappedActionAdd = false;
              });
            },
            onTapDown: (_) {
              setState(() {
                isTappedActionAdd = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                isTappedActionAdd = false;
              });
              if (IBUserApp.current != null) {
                IBWidgetApp.pushWidget(IBWidgetEventCreate(), context);
              }
              else {
                IBWidgetApp.pushWidget(IBWidgetUserCreate(onComplete: () {
                  IBWidgetApp.pushWidget(IBWidgetEventCreate(), context);
                }), context);
              }
            },
          ),
          IBUserApp.current != null ? LayoutBuilder(builder: (context, constraints) {
            var outsetCountEvents = 0;
            var sizeIcon = sizeActionUserApp - (sizeCountEvents*2*outsetCountEvents);
            var marginVertical = (constraints.maxHeight - sizeIcon)/2;
            return GestureDetector(
              child: Container(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: IBWidgetUserIcon(
                            IBUserApp.current.id
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: sizeCountEvents*outsetCountEvents
                        ),
                      ),
                    ),
                    eventsUserAppCreated.isNotEmpty ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        child: Center(
                          child: Text(
                            eventsUserAppCreated.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(sizeCountEvents/2),
                            color: Colors.red
                        ),
                        height: sizeCountEvents,
                        margin: EdgeInsets.only(
                          bottom: marginVertical - sizeCountEvents*outsetCountEvents,
                        ),
                        width: sizeCountEvents,
                      ),
                    ) : Container(),
                    eventsUserAppFollowing.isNotEmpty ? Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        child: Center(
                          child: Text(
                            eventsUserAppFollowing.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(sizeCountEvents/2),
                            color: Colors.red
                        ),
                        height: sizeCountEvents,
                        margin: EdgeInsets.only(
                          bottom: marginVertical - sizeCountEvents*outsetCountEvents,
                        ),
                        width: sizeCountEvents,
                      ),
                    ) : Container()
                  ],
                ),
                height: sizeActionUserApp,
                margin: EdgeInsets.only(
                    right: spacingHorizontal
                ),
                width: sizeActionUserApp,
              ),
              onTapUp: (_) {
                IBWidgetApp.pushWidget(IBWidgetUser(user: IBUserApp.current), context);
              },
            );
          }) : GestureDetector(
              child: Container(
                child: Icon(
                  Icons.person,
                  color: isTappedActionUser ? IBColors.actionTappedDown : Colors.white,
                  size: sizeActionIcon,
                ),
                margin: EdgeInsets.only(
                    right: spacingHorizontal
                ),
              ),
              onTapCancel: () {
                setState(() {
                  isTappedActionUser = false;
                });
              },
              onTapDown: (_) {
                setState(() {
                  isTappedActionUser = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  isTappedActionUser = false;
                });
                IBWidgetApp.pushWidget(IBWidgetUserCreate(), context);
              }
          ),
        ],
        brightness: Brightness.light,
        backgroundColor: IBColors.logo,
        centerTitle: false,
        elevation: 1.0,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: GestureDetector(
            child: Text(
              IBLocalString.eventsTitle,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            onTapDown: (_) { }
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              IBLocation.isLocationDisabled ? Container(
                child: Center(
                  child: Text(
                    IBLocalString.eventsLocationEnable,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                color: IBColors.logo80,
                padding: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal,
                    bottom: spacingVertical
                ),
              ) : Container()
            ] + events.map<Widget>((event) => IBWidgetEvent(event, key: Key(event.id))).toList() + <Widget>[
              !isDoneLoading ? Container(
                height: sizeContainerBottom,
              ) : Container()
            ],
            controller: scrollController,
          ),
          countEventsNew > 0 ? GestureDetector(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  child: Text(
                    IBLocalString.eventsNewCount(countEventsNew),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5.0,
                        )
                      ],
                      color: IBColors.logo
                  ),
                  padding: EdgeInsets.only(
                      top: spacingVertical/1.5,
                      left: spacingHorizontal*2,
                      right: spacingHorizontal*2,
                      bottom: spacingVertical/1.5
                  ),
                  margin: EdgeInsets.only(
                    top: spacingVertical,
                  )
              ),
            ),
            onTap: () async {
              scrollController.animateTo(0.0, duration: Duration(milliseconds: millisecondsAnimationScroll), curve: Curves.decelerate);
            },
          ) : Container()
        ],
      ),
    );
  }
}