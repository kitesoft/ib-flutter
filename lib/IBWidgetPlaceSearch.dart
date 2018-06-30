
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/GoogleAPI.dart';

import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestorePlace.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBLocation.dart';

typedef void IBWidgetPlaceSearchCallback(IBFirestorePlace placeSelected);

class IBWidgetPlaceSearch extends StatefulWidget {

  final IBWidgetPlaceSearchCallback onSelect;
  final IBFirestorePlace placeSelected;

  IBWidgetPlaceSearch({this.onSelect, this.placeSelected, Key key}) : super(key: key);

  @override
  IBStateWidgetPlaceSearch createState() {
    return IBStateWidgetPlaceSearch(onSelect: onSelect, placeSelected: placeSelected);
  }
}

class IBStateWidgetPlaceSearch extends State<IBWidgetPlaceSearch> {

  static int lengthMinAutocomplete = 4;

  static int linesMaxPlace = 1;

  static double sizeIcon = 25.0;
  static double sizeHeightContainerTextField = 40.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBWidgetPlaceSearchCallback onSelect;
  IBFirestorePlace placeSelected;

  IBStateWidgetPlaceSearch({this.onSelect, this.placeSelected});

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
                            top: spacingVertical,
//                                  right: iconSize/2
                          ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: linesMaxPlace,
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
                        size: sizeIcon,
                      ),
                    ),
                  )
                ],
              ),
              height: sizeHeightContainerTextField,
              margin: EdgeInsets.only(
                left: spacingHorizontal,
                right: spacingHorizontal,
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
                                            top: spacingVertical
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
                                            top: spacingVertical/2,
                                            bottom: spacingVertical
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
                          left: spacingHorizontal
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
    else if (text.trim().length > lengthMinAutocomplete && text.length >= textControllerPlace.text.length) {
      var autocompletions = await GoogleAPI.autocomplete(text: text, lat: IBLocation.latitude, lon: IBLocation.longitude);
      var places = autocompletions.map<IBFirestorePlace>((gPlace) => IBFirestorePlace.googlePlace(gPlace)).toList();
      var filteredPlaces = places.where((place) => IBFirestorePlace.typesEventValid.contains(place.type)).toList();
      setState(() {
        this.places = filteredPlaces;
      });
    }
  }
}