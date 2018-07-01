
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetEvent.dart';
import 'package:ib/IBWidgetUserCreate.dart';

class IBWidgetPlace extends StatefulWidget {

  final IBFirestorePlace placePayload;

  IBWidgetPlace(this.placePayload, {Key key}) : super(key: key);

  @override
  IBStateWidgetPlace createState() {
    return IBStateWidgetPlace(placePayload);
  }
}

class IBStateWidgetPlace extends State<IBWidgetPlace> {

  static const lengthLoadEvents = 5;

  static const sizeContainerBottom = 100.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBFirestorePlace placePayload;
  IBFirestorePlace place;

  IBStateWidgetPlace(this.placePayload) {
    this.place = IBFirestorePlace(placePayload.id, placePayload.name, placePayload.type);
  }

  var eventsActive = List<IBFirestoreEvent>();
  var eventsInactive = List<IBFirestoreEvent>();

  var isUserAppFollowing = false;

  bool get isDoneLoading {
    return isDoneLoadingActive && isDoneLoadingInactive;
  }
  var isDoneLoadingActive = false;
  var isDoneLoadingInactive = false;

  var isLoading = false;
  var isTappedAction = false;

  var scrollController = ScrollController();


  @override
  void initState() {

    super.initState();

    IBLocalString.context = context;

    if (IBUserApp.current != null) {
      isUserAppFollowing = IBUserApp.current.placesFollowing.where((p) => p.id == placePayload.id).isNotEmpty;
    }

    setupAsync();

    scrollController.addListener(() {
      if (!isDoneLoading && !isLoading && scrollController.offset == scrollController.position.maxScrollExtent) {
        loadEvents();
      }
    });
  }


  setupAsync() async {
    loadEvents();
  }


  loadEvents() async {

    isLoading = true;

    var events = List<IBFirestoreEvent>();

    if (!isDoneLoadingActive) {
      events = await IBFirestore.getEventsIndexed(idPlace: place.id, typePlace: place.type, isActive: true, sizeLimit: lengthLoadEvents, countFollowersStartAfter: eventsActive.isNotEmpty ? eventsActive.last.countFollowersDouble : null);
      if (events.length < lengthLoadEvents) {
        isDoneLoadingActive = true;
      }
      if (events.isNotEmpty) {
        setState(() {
          this.eventsActive.addAll(events);
        });
      }
    }
    else if (!isDoneLoadingInactive) {
      events = await IBFirestore.getEventsIndexed(idPlace: place.id, typePlace: place.type, isActive: false, sizeLimit: lengthLoadEvents, countFollowersStartAfter: eventsInactive.isNotEmpty ? eventsInactive.last.countFollowersDouble : null);
      if (events.length < lengthLoadEvents) {
        setState(() {
          isDoneLoadingInactive = true;
        });
      }
      if (events.isNotEmpty) {
        setState(() {
          this.eventsInactive.addAll(events);
        });
      }
    }

    isLoading = false;

    if (events.length < lengthLoadEvents && (!isDoneLoadingActive || !isDoneLoadingInactive)) {
      loadEvents();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: IBColors.logo,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          actions: [
            place != null ? PopupMenuButton<String>(
              child: Container(
                child: Icon(
                  Icons.done,
                  color: isTappedAction ?
                  IBColors.tappedDownLight : isUserAppFollowing ?
                  Colors.white : Colors.white70,
                ),
                margin: EdgeInsets.only(
                    right: spacingHorizontal
                ),
              ),
              onSelected: (value) {
                if (value == IBLocalString.placeFollowing) {
                  if (IBUserApp.current != null) {
                    follow();
                  }
                  else {
                    IBWidgetApp.pushWidget(IBWidgetUserCreate(onCreate: () {
                      follow();
                    }), context);
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                var items = List<PopupMenuItem<String>>();
                items.addAll([
                  PopupMenuItem<String>(
                    value: IBLocalString.userActionFollowing,
                    child: Row(
                      children: <Widget>[
                        Text(
                            IBLocalString.userActionFollowing
                        ),
                        Container(
                          child: Icon(
                            Icons.done,
                            color: isUserAppFollowing ? IBColors.logo : Colors.grey,
                          ),
                          margin: EdgeInsets.only(
                              left: spacingHorizontal/2
                          ),
                        )
                      ],
                    ),
                  ),
                ]);
                return items;
              },
            ) : Container()
          ],
          centerTitle: false,
          elevation: 1.0,
          title: Text(
            place.name,
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body: ListView(
          children: (eventsActive + eventsInactive).map<Widget>((event) => IBWidgetEvent(event)).toList() + <Widget>[
            !isDoneLoading ? Container(
              height: sizeContainerBottom,
            ) : Container()
          ],
          controller: scrollController,
        )
    );
  }

  follow() {
    IBFirestore.followPlace(place, follow: !isUserAppFollowing);
    setState(() {
      isUserAppFollowing = !isUserAppFollowing;
      if (isUserAppFollowing) {
        place.idsFollowers.add(IBUserApp.current.id);
      }
      else {
        place.idsFollowers.remove(IBUserApp.current.id);
      }
    });
  }
}