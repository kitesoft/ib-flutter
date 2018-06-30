
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/GoogleAPI.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDateTime.dart';
import 'package:ib/IBFirestoreEvent.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBLocation.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetGroupCreate.dart';
import 'package:ib/IBWidgetPlaceSearch.dart';


class IBWidgetEventCreate extends StatefulWidget {

  // edit mode
  final IBFirestoreEvent event;
  // when opening from group widget
  final IBFirestoreGroup group;

  IBWidgetEventCreate({this.event, this.group, Key key}) : super(key: key);

  @override
  IBStateWidgetEventCreate createState() {
    return IBStateWidgetEventCreate(event: event, group: group);
  }
}


class IBStateWidgetEventCreate extends State<IBWidgetEventCreate> {

  static int lengthMaxDescription = 150;
  static int lengthMaxName = 35;

  static int lengthMinDescription = 10;
  static int lengthMinName = 6;

  static int linesMaxDescription = 3;
  static int linesMaxName = 1;

  static int requestDelayMilliseconds = 500;

  static double sizeIcon = 25.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBFirestoreEvent event;
  IBFirestoreGroup group;

  IBStateWidgetEventCreate({this.event, this.group});

  DateTime dayEnd;
  DateTime dayStart;

  var didGetGroups = false;

  var focusNodePlace = FocusNode();

  IBFirestoreGroup groupPayload;
  IBFirestorePlace placePayload; // only for editing

  bool get isCreateEnabled {
    return textControllerName.text.trim().length >= lengthMinName && textControllerDescription.text.trim().length >= lengthMinDescription && (placeSelected != null || placePayload != null) && dayStart != null && dayEnd != null && timeOfDayEnd != null && timeOfDayStart != null && isEndTimeOfDayValid;
  }

  var isCreating = false;

  bool get isEditEnabled {
    return event.name != textControllerName.text.trim() || event.description != textControllerDescription.text.trim() || (placeSelected != null ? event.placePayload.id != placeSelected.id : false) || event.timestampStart != timestampStart || event.timestampEnd != timestampEnd || (event.idGroup != null && groupPayload != null ? event.idGroup != groupPayload.id : (event.idGroup == null) != (groupPayload == null));
  }

  bool get isEditMode {
    return event != null;
  }

  bool get isEndTimeOfDayValid {
    var isValid = true;
    if (dayStart != null && timeOfDayEnd != null) {
      isValid = timestampEnd > DateTime.now().millisecondsSinceEpoch/1000;
    }
    if (dayStart != null && timeOfDayEnd != null && dayEnd != null && timeOfDayStart != null) {
      isValid = timestampEnd > timestampStart;
    }
    return isValid;
  }

  var isIcon1TappedDown = false;

  var isTappedPlace = false;
  var isTappedEndDate = false;
  var isTappedStartDate = false;
  var isTappedEndTimeOfDate = false;
  var isTappedStartTimeOfDate = false;

  var groupsPayloads = List<IBFirestoreGroup>();

  IBFirestorePlace placeSelected;

  var scrollController = ScrollController();

  var textControllerDescription = TextEditingController();
  var textControllerName = TextEditingController();

  TimeOfDay timeOfDayStart;
  TimeOfDay timeOfDayEnd;

  double get timestampStart {
    return IBDateTime.dateWith(day: dayStart, timeOfDay: timeOfDayStart).millisecondsSinceEpoch/1000;
  }

  double get timestampEnd {
    return IBDateTime.dateWith(day: dayEnd, timeOfDay: timeOfDayEnd).millisecondsSinceEpoch/1000;
  }


  @override
  void initState() {

    super.initState();

    // IMPORTANT: determine locale
    IBLocalString.context = context;

    // only for testing
    IBLocation.getLocationInfo();

    if (group != null) {
      groupPayload = group;
    }

    if (event != null) {
      textControllerName.text = event.name;
      textControllerDescription.text = event.description;
      placePayload = event.placePayload;
      var dateStart = DateTime.fromMillisecondsSinceEpoch(event.timestampStart.toInt()*1000);
      var dateEnd = DateTime.fromMillisecondsSinceEpoch(event.timestampEnd.toInt()*1000);
      dayStart = DateTime(dateStart.year, dateStart.month, dateStart.day);
      dayEnd = DateTime(dateEnd.year, dateEnd.month, dateEnd.day);
      timeOfDayStart = TimeOfDay.fromDateTime(dateStart);
      timeOfDayEnd = TimeOfDay.fromDateTime(dateEnd);
      if (event.idGroup != null) {
        groupPayload = IBFirestoreGroup.firestore(event.idGroup, IBFirestore.groupsPayloads[event.idGroup]);
      }
    }

    groupsPayloads = IBUserApp.current.idsGroups.map<IBFirestoreGroup>((id) => IBFirestoreGroup.firestore(id, IBFirestore.groupsPayloads[id])).toList();

    setupAsync();
  }


  setupAsync() async { }


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
            GestureDetector(
                child: Center(
                  child: Container(
                    child: Text(
                      event != null ? IBLocalString.eventCreateEdit : IBLocalString.eventCreate,
                      style: TextStyle(
                          color: isCreateEnabled && (!isEditMode || isEditEnabled) ?
                          isIcon1TappedDown ? IBColors.actionTappedDown : Colors.white :
                          IBColors.actionDisable,
                          fontSize: Theme.of(context).textTheme.title.fontSize,
                          fontWeight: Theme.of(context).textTheme.title.fontWeight
                      ),
                    ),
                    margin: EdgeInsets.only(
                        right: spacingHorizontal
                    ),
                  ),
                ),
                onTapCancel: () {
                  setState(() {
                    isIcon1TappedDown = false;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    isIcon1TappedDown = true;
                  });
                },
                onTapUp: (_) async {
                  if (isCreateEnabled && (!isEditMode || isEditEnabled) && !isCreating) {
                    isCreating = true;
                    await createEvent();
                    Navigator.pop(context);
                  }
                }
            )
          ],
          centerTitle: false,
          elevation: 1.0,
          title: GestureDetector(
              child: Text(
                event != null ? event.name : IBLocalString.eventCreateTitle,
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onTapDown: (_) {}
          ),
        ),
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        TextField(
                          controller: textControllerName,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                top: spacingVertical,
                                //                                  right: iconSize/2
                              ),
                              hintText: IBLocalString.eventCreateNameHint
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: linesMaxName,
                          maxLength: lengthMaxName,
                          onChanged: (_) {
                            setState(() {

                            });
                          },
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Icon(
                              Icons.done,
                              color: textControllerName.text.trim().length >= lengthMinName ? IBColors.logo : Colors.grey,
                              size: sizeIcon,
                            ),
                            margin: EdgeInsets.only(
                                top: spacingVertical/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                      right: spacingHorizontal,
                    ),
                  ),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        TextField(
                          controller: textControllerDescription,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                top: spacingVertical,
//                                  right: iconSize/2
                              ),
                              hintText: IBLocalString.eventCreateHintDescription
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: linesMaxDescription,
                          maxLength: lengthMaxDescription,
                          onChanged: (_) {
                            setState(() {

                            });
                          },
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: Icon(
                              Icons.done,
                              color: textControllerDescription.text.trim().length >= lengthMinDescription ? IBColors.logo : Colors.grey,
                              size: sizeIcon,
                            ),
                            margin: EdgeInsets.only(
                                top: spacingVertical/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                      right: spacingHorizontal,
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    height: 0.5,
                    margin: EdgeInsets.only(
                        top: spacingVertical,
                        left: spacingHorizontal
                    ),
                  ),
                  Container(
                    child: Text(
                      IBLocalString.eventCreateWhere,
                      style: TextStyle(
                          fontSize: 16.0
                      ),
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: spacingHorizontal,
                        vertical: spacingVertical
                    ),
                  ),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          child: Text(
                            placeSelected != null ? placeSelected.name : placePayload != null ? placePayload.name : IBLocalString.eventCreateSelectPlace,
                            style: TextStyle(
                                color: isTappedPlace ? IBColors.logo : Colors.black,
                                fontSize: 16.0
                            ),
                          ),
                          onTapCancel: () {
                            setState(() {
                              isTappedPlace = false;
                            });
                          },
                          onTapDown: (_) {
                            setState(() {
                              isTappedPlace = true;
                            });
                          },
                          onTapUp: (_) {
                            setState(() {
                              isTappedPlace = false;
                            });
                            IBWidgetApp.pushWidget(IBWidgetPlaceSearch(placeSelected: placeSelected, onSelect: (place) {
                              setState(() {
                                this.placeSelected = place;
                              });
                            }), context);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child: Icon(
                              Icons.done,
                              color: placeSelected != null || placePayload != null ? IBColors.logo : Colors.grey,
                              size: sizeIcon,
                            ),
                            margin: EdgeInsets.only(
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: spacingVertical,
                      left: spacingHorizontal,
                      right: spacingHorizontal,
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    height: 0.5,
                    margin: EdgeInsets.only(
                        top: spacingVertical,
                        left: spacingHorizontal
                    ),
                  ),
                  Container(
                    child: Text(
                      IBLocalString.eventCreateWhen,
                      style: TextStyle(
                          fontSize: 16.0
                      ),
                    ),
                    margin: EdgeInsets.only(
                        top: spacingHorizontal,
                        left: spacingVertical
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          IBLocalString.eventCreateStarts,
                          style: TextStyle(
                              fontSize: 16.0
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: spacingVertical,
                          left: spacingHorizontal,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                dayStart != null ? IBLocalString.eventCreateFormatDay(dayStart) : IBLocalString.eventCreateSelectDay,
                                style: TextStyle(
                                    color: isTappedStartDate ? IBColors.buttonTappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: dayStart != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
                            left: spacingHorizontal,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            isTappedStartDate = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            isTappedStartDate = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            isTappedStartDate = false;
                          });
                          var datePicker = showDatePicker(
                            context: this.context,
                            initialDate: dayStart ?? IBDateTime.today,
                            firstDate: IBDateTime.today,
                            lastDate: dayEnd ?? DateTime(IBDateTime.now.year, IBDateTime.now.month == 12 ? 1 : IBDateTime.now.month + 1, IBDateTime.now.day),
                            initialDatePickerMode: DatePickerMode.day,
                          );
                          var newDate = await datePicker;
                          setState(() {
                            dayStart = newDate;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                timeOfDayStart != null ? timeOfDayStart.format(context) : IBLocalString.eventCreateSelectTimeOfDay,
                                style: TextStyle(
                                    color: isTappedStartTimeOfDate ? IBColors.buttonTappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: timeOfDayStart != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
                            left: spacingHorizontal,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            isTappedStartTimeOfDate = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            isTappedStartTimeOfDate = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            isTappedStartTimeOfDate = false;
                          });
                          var timePicker = showTimePicker(
                            context: this.context,
                            initialTime: timeOfDayStart ?? TimeOfDay(hour: 12, minute: 0),
                          );
                          var newStartTimeOfDay = await timePicker;
                          setState(() {
                            timeOfDayStart = newStartTimeOfDay;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          IBLocalString.eventCreateEnds,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: spacingVertical,
                          left: spacingHorizontal,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                dayEnd != null ? IBLocalString.eventCreateFormatDay(dayEnd) : IBLocalString.eventCreateSelectDay,
                                style: TextStyle(
                                    color: isTappedEndDate ? IBColors.buttonTappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: dayEnd != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
                            left: spacingHorizontal/2,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            isTappedEndDate = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            isTappedEndDate = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            isTappedEndDate = false;
                          });
                          var datePicker = showDatePicker(
                            context: this.context,
                            initialDate: dayEnd ?? dayStart ?? IBDateTime.today,
                            firstDate: dayStart ?? IBDateTime.today,
                            lastDate: DateTime(IBDateTime.now.year, IBDateTime.now.month == 12 ? 1 : IBDateTime.now.month + 1, IBDateTime.now.day),
                            initialDatePickerMode: DatePickerMode.day,
                          );
                          var newDate = await datePicker;
                          setState(() {
                            dayEnd = newDate;
                          });
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                timeOfDayEnd != null ? timeOfDayEnd.format(context) : IBLocalString.eventCreateSelectTimeOfDay,
                                style: TextStyle(
                                    color: isTappedEndTimeOfDate ? IBColors.buttonTappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  !isEndTimeOfDayValid ? Icons.clear : Icons.done,
                                  color: timeOfDayEnd != null && isEndTimeOfDayValid ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: spacingVertical,
                            left: spacingHorizontal,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            isTappedEndTimeOfDate = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            isTappedEndTimeOfDate = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            isTappedEndTimeOfDate = false;
                          });
                          var timePicker = showTimePicker(
                            context: this.context,
                            initialTime: timeOfDayEnd ?? TimeOfDay(hour: 12, minute: 0),
                          );
                          var newEndTimeOfDay = await timePicker;
                          setState(() {
                            timeOfDayEnd = newEndTimeOfDay;
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.black26,
                    height: 0.5,
                    margin: EdgeInsets.only(
                        top: spacingHorizontal,
                        left: spacingVertical
                    ),
                  ),
                  PopupMenuButton<String>(
                    child: Container(
                      child: Text(
                          IBLocalString.eventCreateGroup(name: groupPayload == null || IBUserApp.current == null ? IBLocalString.eventCreateEveryone : groupPayload.name),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0
                          )
                      ),
                      margin: EdgeInsets.only(
                          top: spacingHorizontal,
                          left: spacingVertical
                      ),
                    ),
                    onSelected: (value) {
                      if (value == IBLocalString.eventCreateEveryone) {
                        setState(() {
                          groupPayload = null;
                        });
                      }
                      else if (value == IBLocalString.eventCreateGroupCreate) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IBWidgetGroupCreate(onComplete: (group) {
                          setState(() {
                            this.groupPayload = group;
                          });
                        })));
                      }
                      else {
                        setState(() {
                          this.groupPayload = groupsPayloads.firstWhere((payload) => payload.id == value);
                        });
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: IBLocalString.eventCreateEveryone,
                          child: Row(
                            children: <Widget>[
                              Text(
                                  IBLocalString.eventCreateEveryone
                              ),
                              groupPayload == null ?
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: IBColors.logo,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal
                                ),
                              ) : Container()
                            ],
                          ),
                        )
                      ] + groupsPayloads.map((payload) {
                        return PopupMenuItem<String>(
                          value: payload.id,
                          child: Row(
                            children: <Widget>[
                              Text(
                                  payload.name
                              ),
                              groupPayload != null && groupPayload.id == payload.id ?
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: IBColors.logo,
                                ),
                                margin: EdgeInsets.only(
                                    left: spacingHorizontal
                                ),
                              ) : Container()
                            ],
                          ),
                        );
                      }).toList() + [
                        PopupMenuItem<String>(
                          value: IBLocalString.eventCreateGroupCreate,
                          child: Text(
                              IBLocalString.eventCreateGroupCreate
                          ),
                        )
                      ];
                    },
                  ),
                ],
                controller: scrollController,
                shrinkWrap: true,
              ),
            ),
          ],
        )
    );
  }


  createEvent() async {

    if (isEditMode) {
      event.name = textControllerName.text.trim();
      event.description = textControllerDescription.text.trim();
      event.timestampStart = timestampStart;
      event.timestampEnd = timestampEnd;
      if (placeSelected != null) {
        event.places = await getPayloadsPlaces();
      }
      if (groupPayload != null) {
        event.idGroup = groupPayload.id;
      }
    }
    else {
      var payloadsPlaces = await getPayloadsPlaces();
      event = IBFirestoreEvent(textControllerName.text.trim(), textControllerDescription.text.trim(), IBUserApp.current.id, groupPayload != null ? groupPayload.id : null, payloadsPlaces, timestampStart, timestampEnd);
    }

    await IBFirestore.addEvent(event);

    if (isEditMode) {
      IBUserApp.current.idsFollowers.forEach((idUser) {
        var userPayload = IBFirestore.usersPayloads[idUser];
        IBMessaging.send(event.name, IBLocalString.eventCreateMessageEditUserFollower(userPayload.codeLanguage ?? "es"), {IBFirestore.ID_EVENT : event.id}, userPayload.token);
      });
    }
    else {

      IBUserApp.current.idsFollowers.forEach((idUser) {
        var userPayload = IBFirestore.usersPayloads[idUser];
        IBMessaging.send(event.name, IBLocalString.eventCreateMessageUserFollower(IBUserApp.current.name, userPayload.codeLanguage ?? "es"), {IBFirestore.ID_EVENT : event.id}, userPayload.token);
      });

      var placesPayloadsMessage = event.places.where((payload) => IBFirestorePlace.typesEventValid.contains(payload.type) || payload.isTypeCity);

      placesPayloadsMessage.forEach((payloadPlace) async {
        var place = await IBFirestore.getPlace(payloadPlace.id);
        place.idsFollowers.forEach((idUser) {
          var userPayload = IBFirestore.usersPayloads[idUser];
          IBMessaging.send(event.name, IBLocalString.eventCreateMessagePlaceFollower(payloadPlace.name, userPayload.codeLanguage ?? "es"), {IBFirestore.ID_EVENT : event.id}, userPayload.token);
        });
      });
    }
  }


  Future<List<IBFirestorePlace>> getPayloadsPlaces() async {

    var completer = Completer<List<IBFirestorePlace>>();

    var places = List<IBFirestorePlace>();

    var geocode = await GoogleAPI.geocodePlaceId(placeId: placeSelected.id);
    placeSelected.addGeocode(geocode);
    places.add(placeSelected);

    var geocodeCoordinates = await GoogleAPI.geocodeCoordinates(lon: placeSelected.lon, lat: placeSelected.lat);
    var geocodePlaces = geocodeCoordinates.map<IBFirestorePlace>((gPlace) => IBFirestorePlace.googlePlace(gPlace)).toList();
    var includedPlaces = geocodePlaces.where((place) => IBFirestorePlace.typesEventsAdd.contains(place.type));
    places.addAll(includedPlaces);

    var locality = geocodePlaces.where((place) => place.isTypeCity);
    if (locality.isNotEmpty) {
      IBFirestore.addPlaceWithDistances(locality.first);
    }

    completer.complete(places);

    return completer.future;
  }
}