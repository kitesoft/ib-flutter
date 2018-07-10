
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
import 'package:ib/IBWidgetPlaceSelect.dart';


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

  static const String IS_TAPPED_ACTION = "is_tapped_action";
  static const String IS_TAPPED_PLACE = "is_tapped_place";
  static const String IS_TAPPED_END_DATE = "is_tapped_end_date";
  static const String IS_TAPPED_START_DATE = "is_tapped_start_date";
  static const String IS_TAPPED_END_TIME_OF_DAY = "is_tapped_end_time_of_day";
  static const String IS_TAPPED_START_TIME_OF_DAY = "is_tapped_start_time_of_day";

  static const int LENGTH_MAX_DESCRIPTION = 150;
  static const int LENGTH_MAX_NAME = 35;

  static const int LENGTH_MIN_DESCRIPTION = 10;
  static const int LENGTH_MIN_NAME = 6;

  static const int LINES_MAX_DESCRIPTION = 3;
  static const int LINES_MAX_NAME = 1;

  static const int MILLISECONDS_DELAY_REQUESTS = 500;

  static const double SIZE_ICON = 25.0;

  static const double SPACING_HORIZONTAL = 8.0;
  static const double SPACING_VERTICAL = 6.0;
  static const double SPACING_VERTICAL_EDGE = 8.0;

  IBFirestoreEvent event;
  IBFirestoreGroup group;

  IBStateWidgetEventCreate({this.event, this.group});

  DateTime dayEnd;
  var dayEndLast = DateTime(IBDateTime.dateNow.year + 1, IBDateTime.dateNow.month, IBDateTime.dateNow.day); // one year after
  DateTime dayStart;

  var didGetGroups = false;

  var focusNodePlace = FocusNode();

  IBFirestoreGroup groupPayload;
  IBFirestorePlace placePayload; // only for editing

  bool get isCreateEnabled {
    return textControllerName.text.trim().length >= LENGTH_MIN_NAME && textControllerDescription.text.trim().length >= LENGTH_MIN_DESCRIPTION && (placeSelected != null || placePayload != null) && dayStart != null && dayEnd != null && timeOfDayEnd != null && timeOfDayStart != null && isEndTimeOfDayValid;
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

  var groupsPayloads = List<IBFirestoreGroup>();

  IBFirestorePlace placeSelected;

  var scrollController = ScrollController();

  var taps = {IS_TAPPED_ACTION : false, IS_TAPPED_PLACE : false, IS_TAPPED_END_DATE : false, IS_TAPPED_START_DATE : false, IS_TAPPED_END_TIME_OF_DAY : false, IS_TAPPED_START_TIME_OF_DAY : false};

  var textControllerDescription = TextEditingController();
  var textControllerName = TextEditingController();

  TimeOfDay timeOfDayEnd;
  var timeOfDayInitial = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay timeOfDayStart;

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
                          taps[IS_TAPPED_ACTION] ? IBColors.tappedDownLight : Colors.white :
                          IBColors.actionDisable,
                          fontSize: Theme.of(context).textTheme.title.fontSize,
                          fontWeight: Theme.of(context).textTheme.title.fontWeight
                      ),
                    ),
                    margin: EdgeInsets.only(
                        right: SPACING_HORIZONTAL
                    ),
                  ),
                ),
                onTapCancel: () {
                  setState(() {
                    taps[IS_TAPPED_ACTION] = false;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    taps[IS_TAPPED_ACTION] = true;
                  });
                },
                onTapUp: (_) async {
                  if (isCreateEnabled && (!isEditMode || isEditEnabled) && !isCreating) {
                    isCreating = true;
                    await createEvent();
                    Navigator.pop(context);
                  }
                  if (!isCreating) {
                    setState(() {
                      taps[IS_TAPPED_ACTION] = false;
                    });
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
                                top: SPACING_VERTICAL,
                                //                                  right: iconSize/2
                              ),
                              hintText: IBLocalString.eventCreateNameHint
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: LINES_MAX_NAME,
                          maxLength: LENGTH_MAX_NAME,
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
                              color: textControllerName.text.trim().length >= LENGTH_MIN_NAME ? IBColors.logo : Colors.grey,
                              size: SIZE_ICON,
                            ),
                            margin: EdgeInsets.only(
                                top: SPACING_VERTICAL/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL,
                      right: SPACING_HORIZONTAL,
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
                                top: SPACING_VERTICAL,
//                                  right: iconSize/2
                              ),
                              hintText: IBLocalString.eventCreateHintDescription
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: LINES_MAX_DESCRIPTION,
                          maxLength: LENGTH_MAX_DESCRIPTION,
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
                              color: textControllerDescription.text.trim().length >= LENGTH_MIN_DESCRIPTION ? IBColors.logo : Colors.grey,
                              size: SIZE_ICON,
                            ),
                            margin: EdgeInsets.only(
                                top: SPACING_VERTICAL/2
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL,
                      right: SPACING_HORIZONTAL,
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    height: 0.5,
                    margin: EdgeInsets.only(
                        top: SPACING_VERTICAL,
                        left: SPACING_HORIZONTAL
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
                        horizontal: SPACING_HORIZONTAL,
                        vertical: SPACING_VERTICAL
                    ),
                  ),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          child: Text(
                            placeSelected != null ? placeSelected.name : placePayload != null ? placePayload.name : IBLocalString.eventCreateSelectPlace,
                            style: TextStyle(
                                color: taps[IS_TAPPED_PLACE] ? IBColors.tappedDown : Colors.black,
                                fontSize: 16.0
                            ),
                          ),
                          onTapCancel: () {
                            setState(() {
                              taps[IS_TAPPED_PLACE] = false;
                            });
                          },
                          onTapDown: (_) {
                            setState(() {
                              taps[IS_TAPPED_PLACE] = true;
                            });
                          },
                          onTapUp: (_) {
                            setState(() {
                              taps[IS_TAPPED_PLACE] = false;
                            });
                            IBWidgetApp.pushWidget(IBWidgetPlaceSelect(placeSelected: placeSelected, onSelect: (place) {
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
                              size: SIZE_ICON,
                            ),
                            margin: EdgeInsets.only(
                            ),
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL,
                      right: SPACING_HORIZONTAL,
                    ),
                  ),
                  Container(
                    color: Colors.black26,
                    height: 0.5,
                    margin: EdgeInsets.only(
                        top: SPACING_VERTICAL,
                        left: SPACING_HORIZONTAL
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
                        top: SPACING_HORIZONTAL,
                        left: SPACING_VERTICAL
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
                          top: SPACING_VERTICAL,
                          left: SPACING_HORIZONTAL,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                dayStart != null ? IBLocalString.eventCreateFormatDay(dayStart) : IBLocalString.eventCreateSelectDay,
                                style: TextStyle(
                                    color: taps[IS_TAPPED_START_DATE] ? IBColors.tappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: dayStart != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: SPACING_HORIZONTAL/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
                            left: SPACING_HORIZONTAL,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            taps[IS_TAPPED_START_DATE] = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            taps[IS_TAPPED_START_DATE] = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            taps[IS_TAPPED_START_DATE] = false;
                          });
                          var datePicker = showDatePicker(
                            context: this.context,
                            initialDate: dayStart ?? IBDateTime.today,
                            firstDate: IBDateTime.today,
                            lastDate: dayEnd ?? DateTime(IBDateTime.dateNow.year, IBDateTime.dateNow.month == 12 ? 1 : IBDateTime.dateNow.month + 1, IBDateTime.dateNow.day),
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
                                    color: taps[IS_TAPPED_START_TIME_OF_DAY] ? IBColors.tappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: timeOfDayStart != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: SPACING_HORIZONTAL/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
                            left: SPACING_HORIZONTAL,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            taps[IS_TAPPED_START_TIME_OF_DAY] = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            taps[IS_TAPPED_START_TIME_OF_DAY] = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            taps[IS_TAPPED_START_TIME_OF_DAY] = false;
                          });
                          var timePicker = showTimePicker(
                            context: this.context,
                            initialTime: timeOfDayStart ?? timeOfDayInitial,
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
                          top: SPACING_VERTICAL,
                          left: SPACING_HORIZONTAL,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                dayEnd != null ? IBLocalString.eventCreateFormatDay(dayEnd) : IBLocalString.eventCreateSelectDay,
                                style: TextStyle(
                                    color: taps[IS_TAPPED_END_DATE] ? IBColors.tappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.done,
                                  color: dayEnd != null ? IBColors.logo : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: SPACING_HORIZONTAL
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
                            left: SPACING_HORIZONTAL/2,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            taps[IS_TAPPED_END_DATE] = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            taps[IS_TAPPED_END_DATE] = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            taps[IS_TAPPED_END_DATE] = false;
                          });
                          var datePicker = showDatePicker(
                            context: this.context,
                            initialDate: dayEnd ?? dayStart ?? IBDateTime.today,
                            firstDate: dayStart ?? IBDateTime.today,
                            lastDate: DateTime(IBDateTime.dateNow.year + 1, IBDateTime.dateNow.month, IBDateTime.dateNow.day),
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
                                    color: taps[IS_TAPPED_END_TIME_OF_DAY] ? IBColors.tappedDown : Colors.black,
                                    fontSize: 16.0
                                ),
                              ),
                              Container(
                                child: Icon(
                                  !isEndTimeOfDayValid ? Icons.clear : Icons.done,
                                  color: timeOfDayEnd != null ? isEndTimeOfDayValid ? IBColors.logo : Colors.red : Colors.grey,
                                ),
                                margin: EdgeInsets.only(
                                    left: SPACING_HORIZONTAL/2
                                ),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
                            left: SPACING_HORIZONTAL,
                          ),
                        ),
                        onTapCancel: () {
                          setState(() {
                            taps[IS_TAPPED_END_TIME_OF_DAY] = false;
                          });
                        },
                        onTapDown: (_) {
                          setState(() {
                            taps[IS_TAPPED_END_TIME_OF_DAY] = true;
                          });
                        },
                        onTapUp: (_) async {
                          setState(() {
                            taps[IS_TAPPED_END_TIME_OF_DAY] = false;
                          });
                          var timePicker = showTimePicker(
                            context: this.context,
                            initialTime: timeOfDayEnd ?? timeOfDayInitial,
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
                        top: SPACING_HORIZONTAL,
                        left: SPACING_VERTICAL
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
                          top: SPACING_HORIZONTAL,
                          left: SPACING_VERTICAL,
                          bottom: SPACING_VERTICAL_EDGE,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == IBLocalString.eventCreateEveryone) {
                        setState(() {
                          groupPayload = null;
                        });
                      }
                      else if (value == IBLocalString.eventCreateGroupCreate) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => IBWidgetGroupCreate(onCreate: (group) {
                          IBUserApp.current.idsGroups.add(group.id);
                          setState(() {
                            this.groupPayload = group;
                            groupsPayloads = IBUserApp.current.idsGroups.map<IBFirestoreGroup>((id) => IBFirestoreGroup.firestore(id, IBFirestore.groupsPayloads[id])).toList();
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
                                    left: SPACING_HORIZONTAL
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
                                    left: SPACING_HORIZONTAL
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
        IBMessaging.send(event.name, IBLocalString.eventCreateMessageEditUserFollower(userPayload.codeLanguage ?? "es"), {IBMessaging.ID_EVENT : event.id}, userPayload.token);
      });
    }
    else {

      IBUserApp.current.idsFollowers.forEach((idUser) {
        var userPayload = IBFirestore.usersPayloads[idUser];
        IBMessaging.send(event.name, IBLocalString.eventCreateMessageUserFollower(IBUserApp.current.name, userPayload.codeLanguage ?? "es"), {IBMessaging.ID_EVENT : event.id}, userPayload.token);
      });

      var placesPayloadsMessage = event.places.where((payload) => IBFirestorePlace.typesPlacesEvent.contains(payload.type) || payload.isTypeCity);

      placesPayloadsMessage.forEach((payloadPlace) async {
        var place = await IBFirestore.getPlace(payloadPlace.id);
        place.idsFollowers.forEach((idUser) {
          var userPayload = IBFirestore.usersPayloads[idUser];
          IBMessaging.send(event.name, IBLocalString.eventCreateMessagePlaceFollower(payloadPlace.name, userPayload.codeLanguage ?? "es"), {IBMessaging.ID_EVENT : event.id}, userPayload.token);
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
    var includedPlaces = geocodePlaces.where((place) => IBFirestorePlace.typesPlacesEventAdd.contains(place.type));
    places.addAll(includedPlaces);

    var locality = geocodePlaces.where((place) => place.isTypeCity);
    if (locality.isNotEmpty) {
      IBFirestore.addPlaceWithDistances(locality.first);
    }

    completer.complete(places);

    return completer.future;
  }
}