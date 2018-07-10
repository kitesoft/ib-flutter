
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/GoogleAPI.dart';

import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBLocation.dart';

typedef void IBCallbackWidgetPlaceSelect(IBFirestorePlace placeSelected);

class IBWidgetPlaceSelect extends StatefulWidget {

  final IBCallbackWidgetPlaceSelect onSelect;
  final IBFirestorePlace placeSelected;

  IBWidgetPlaceSelect({this.onSelect, this.placeSelected, Key key}) : super(key: key);

  @override
  IBStateWidgetPlaceSelect createState() {
    return IBStateWidgetPlaceSelect(onSelect: onSelect, placeSelected: placeSelected);
  }
}

class IBStateWidgetPlaceSelect extends State<IBWidgetPlaceSelect> {

  static const LENGTH_MIN_AUTOCOMPLETE = 4;

  static const LINES_MAX_PLACE = 1;

  static const SIZE_ICON = 25.0;
  static const SIZE_HEIGHT_CONTAINER_TEXT_FIELD = 40.0;

  static const SPACING_HORIZONTAL = 8.0;
  static const SPACING_VERTICAL = 6.0;
  static const SPACING_VERTICAL_EDGE = 8.0;

  IBCallbackWidgetPlaceSelect onSelect;
  IBFirestorePlace placeSelected;

  IBStateWidgetPlaceSelect({this.onSelect, this.placeSelected});

  List<IBFirestorePlace> places = List<IBFirestorePlace>();

  var textControllerPlace = TextEditingController();

  @override
  void initState() {

    super.initState();

    IBLocalString.context = context;
    // only for testing
    IBLocation.getLocationInfo();

    if (placeSelected != null) {
      textControllerPlace.text = placeSelected.name;
    }

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
          actions: [ ],
          centerTitle: false,
          elevation: 1.0,
          title: GestureDetector(
              child: Text(
                IBLocalString.placeSearchTitle,
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              onTapDown: (_) {}
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      autofocus: true,
                      controller: textControllerPlace,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            top: SPACING_VERTICAL,
//                                  right: iconSize/2
                          ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: LINES_MAX_PLACE,
                      onChanged: (text) {
                        autocomplete(text);
                      },
                      onSubmitted: (text) {
                        autocomplete(text);
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Icon(
                        Icons.done,
                        color: placeSelected != null ? IBColors.logo : Colors.grey,
                        size: SIZE_ICON,
                      ),
                    ),
                  )
                ],
              ),
              height: SIZE_HEIGHT_CONTAINER_TEXT_FIELD,
              margin: EdgeInsets.only(
                left: SPACING_HORIZONTAL,
                right: SPACING_HORIZONTAL,
              ),
            ),
            Container(
              child: Column(
                children: places.map((place) {
                  return GestureDetector(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          place.name,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15.0
                                          ),
                                        ),
                                        margin: EdgeInsets.only(
                                            top: SPACING_VERTICAL
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          place.description,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14.0
                                          ),
                                          maxLines: 2,
                                        ),
                                        margin: EdgeInsets.only(
                                            top: SPACING_VERTICAL/2,
                                            bottom: SPACING_VERTICAL
                                        ),
                                      ),
                                      Container(
                                        color: Colors.black26,
                                        height: 0.5,
                                        margin: EdgeInsets.only(),
                                      ),
                                    ],
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ),
                                Icon(
                                  Icons.done,
                                  color: placeSelected == place ? IBColors.logo : Colors.transparent,
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                          left: SPACING_HORIZONTAL
                      ),
                    ),
                    onTapUp: (_) {
                      Navigator.pop(context);
                      onSelect(place);
                    },
                  );
                }).toList(),
              ),
              color: Colors.white,
            ),
          ],
        )
    );
  }

  autocomplete(String text) async {

    await Future.delayed(Duration(milliseconds: 100));

    if (text.trim().isEmpty) {
      setState(() {
        places = [];
      });
    }
    else if (text.trim().length > LENGTH_MIN_AUTOCOMPLETE && text.length >= textControllerPlace.text.length) {
      var autocompletions = await GoogleAPI.autocomplete(text: text, lat: IBLocation.latitude, lon: IBLocation.longitude);
      var places = autocompletions.map<IBFirestorePlace>((gPlace) => IBFirestorePlace.googlePlace(gPlace)).toList();
      var filteredPlaces = places.where((place) => IBFirestorePlace.typesPlacesEvent.contains(place.type)).toList();
      setState(() {
        this.places = filteredPlaces;
      });
    }
  }
}