
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBLocalString.dart';

import 'package:ib/IBWidgetUserIcon.dart';


typedef void IBWidgetUserSearchCallback(List<IBFirestoreUser> usersPayloadsSelected);

class IBWidgetUserSearch extends StatefulWidget {

  final IBWidgetUserSearchCallback onSelect;
  final List<String> idsExclude;
  final List<String> idsSelected;

  IBWidgetUserSearch({this.idsExclude, this.idsSelected, this.onSelect, Key key}) : super(key: key);

  @override
  IBStateWidgetUserSearch createState() {
    return IBStateWidgetUserSearch(idsExclude: idsExclude, idsSelected: idsSelected, onSelect: onSelect);
  }
}


class IBStateWidgetUserSearch extends State<IBWidgetUserSearch> {

  static int maxLinesPlace = 1;

  static double sizeHeightContainerPayloadUser = 45.0;
  static double sizeHeightContainerTextField = 40.0;
  static double sizeIcon = 25.0;

  static double sizeWidthName = 50.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBWidgetUserSearchCallback onSelect;
  List<String> idsExclude;
  List<String> idsSelected;

  IBStateWidgetUserSearch({this.idsExclude, this.idsSelected, this.onSelect});

  var isTappedAction = false;

  var usersPayloads = List<IBFirestoreUser>();
  var usersPayloadsFiltered = List<IBFirestoreUser>();
  var usersPayloadsSelected = List<IBFirestoreUser>();

  var textControllerPlace = TextEditingController();


  @override
  void initState() {

    super.initState();

    IBLocalString.context = context;

    if (idsExclude == null) {
      idsExclude = [];
    }
    if (idsSelected == null) {
      idsSelected = [];
    }

    var usersPayloads = IBFirestore.usersPayloads.entries.map<IBFirestoreUser>((entry) => IBFirestoreUser.firestore(entry.key, entry.value)).toList();
    setState(() {
      this.usersPayloads = usersPayloads;
      usersPayloadsFiltered = usersPayloads.where((userPayload) => idsSelected.contains(userPayload.id)).toList();
    });

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
                      IBLocalString.userSearch,
                      style: TextStyle(
                          color: isTappedAction ? IBColors.tappedDownLight : Colors.white,
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
                    isTappedAction = false;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    isTappedAction = true;
                  });
                },
                onTapUp: (_) async {
                  setState(() {
                    isTappedAction = false;
                  });
                  Navigator.pop(context);
                  onSelect(usersPayloadsSelected);
                }
            ),
          ],
          centerTitle: false,
          elevation: 1.0,
          title: GestureDetector(
              child: Text(
                IBLocalString.userSearchTitle,
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
              child: Align(
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
                  maxLines: maxLinesPlace,
                  onChanged: (text) {
                    searchUsersPayloads(text);
                  },
                  onSubmitted: (text) {
                    searchUsersPayloads(text);
                  },
                ),
              ),
              height: sizeHeightContainerTextField,
              margin: EdgeInsets.only(
                left: spacingHorizontal,
                right: spacingHorizontal,
              ),
            ),
            Container(
              child: Column(
                children: usersPayloadsFiltered.map((payload) {
                  return GestureDetector(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: IBWidgetUserIcon(
                                    payload.id,
                                  ),
                                  margin: EdgeInsets.only(
                                    top: spacingVertical,
                                    left: spacingHorizontal,
                                    bottom: spacingVertical,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    payload.name,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.0
                                    ),
                                  ),
                                  margin: EdgeInsets.only(
                                      left: spacingHorizontal/2
                                  ),
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              child: Icon(
                                Icons.done,
                                color: usersPayloadsSelected.contains(payload) ? IBColors.logo : Colors.transparent,
                              ),
                              margin: EdgeInsets.only(
                                  right: spacingHorizontal
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black26,
                              height: 0.5,
                              margin: EdgeInsets.only(
                                  left: spacingHorizontal
                              ),
                            ),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent
                              )
                          )
                        ],
                      ),
                      height: sizeHeightContainerPayloadUser,
                      padding: EdgeInsets.only(),
                    ),
                    onTapCancel: () {
                    },
                    onTapDown: (_) {
                    },
                    onTapUp: (_) {
                      if (usersPayloadsSelected.contains(payload)) {
                        setState(() {
                          usersPayloadsSelected.remove(payload);
                        });
                      }
                      else {
                        setState(() {
                          usersPayloadsSelected.add(payload);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              color: Colors.white,
              margin: EdgeInsets.only(),
            ),
          ],
        )
    );
  }


  searchUsersPayloads(String name) async {

    if (name.isEmpty) {
      setState(() {
        this.usersPayloadsFiltered = [];
      });
    }
    else {
      setState(() {
        this.usersPayloadsFiltered = usersPayloads.where((userPayload) => userPayload.name.toLowerCase().contains(name.toLowerCase()) && userPayload.id != IBUserApp.currentId).toList();
      });
    }
  }
}