

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreGroup.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBLocation.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetUserIcon.dart';
import 'package:ib/IBWidgetUserSelect.dart';


typedef void IBCallbackWidgetGroupCreate(IBFirestoreGroup group);


class IBWidgetGroupCreate extends StatefulWidget {

  // edit mode
  final IBFirestoreGroup group;

  final IBCallbackWidgetGroupCreate onCreate;

  IBWidgetGroupCreate({this.group, this.onCreate, Key key}) : super(key: key);

  @override
  IBStateWidgetGroupCreate createState() {
    return IBStateWidgetGroupCreate(group: group, onCreate: onCreate);
  }
}


class IBStateWidgetGroupCreate extends State<IBWidgetGroupCreate> {

  static const IS_TAPPED_ACTION = "is_tapped_action";
  static const IS_TAPPED_SEARCH_USERS = "is_tapped_search_users";

  static const LENGTH_MAX_DESCRIPTION = 150;
  static const LENGTH_MAX_NAME = 35;

  static const LENGTH_MIN_DESCRIPTION = 10;
  static const LENGTH_MIN_NAME = 6;

  static const LINES_MAX_DESCRIPTION = 3;
  static const LINES_MAX_NAME = 1;

  static const SIZE_ICON = 25.0;
  static const SIZE_WIDTH_PAYLOAD = 65.0;

  static const SPACING_HORIZONTAL = 8.0;
  static const SPACING_VERTICAL = 6.0;
  static const SPACING_VERTICAL_EDGE = 8.0;

  IBFirestoreGroup group;
  IBCallbackWidgetGroupCreate onCreate;

  IBStateWidgetGroupCreate({this.group, this.onCreate});

  var focusNodeSearch = FocusNode();

  var idsUsersSelected = List<IBFirestoreUser>();

  bool get isCreateEnabled {
    return textControllerName.text.trim().length >= LENGTH_MIN_NAME && textControllerDescription.text.trim().length >= LENGTH_MIN_DESCRIPTION;
  }

  var isCreating = false;

  bool get isEditEnabled {
    return group.name != textControllerName.text.trim() || group.description != textControllerDescription.text.trim();
  }

  bool get isEditMode {
    return group != null;
  }

  var scrollController = ScrollController();

  var taps = Map<String, bool>();

  var textControllerDescription = TextEditingController();
  var textControllerName = TextEditingController();
  var textControllerSearch = TextEditingController();


  @override
  void initState() {

    super.initState();

    // IMPORTANT: determine locale
    IBLocalString.context = context;

    // only for testing
    IBLocation.getLocationInfo();

    if (group != null) {
      textControllerName.text = group.name;
      textControllerDescription.text = group.description;
    }

    setupAsync();
  }

  setupAsync() async {
//    await IBDefaults.getUpdatedUser();
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
            GestureDetector(
                child: Center(
                  child: Container(
                    child: Text(
                      isEditMode ? IBLocalString.groupCreateEdit : IBLocalString.groupCreate,
                      style: TextStyle(
                          color: isCreateEnabled && (!isEditMode || isEditEnabled) ? taps[IS_TAPPED_ACTION] ?? false ? IBColors.tappedDownLight : Colors.white : IBColors.actionDisable,
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
                    create();
                  }
                  if (!isCreating) {
                    taps[IS_TAPPED_ACTION] = false;
                  }
                }
            ),
          ],
          centerTitle: false,
          elevation: 1.0,
          title: GestureDetector(
              child: Text(
                group != null ? group.name : IBLocalString.groupCreateTitle,
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
              alignment: Alignment.topCenter,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: textControllerName,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
//                                top: spacingVertical,
                                ),
                                hintText: IBLocalString.groupCreateHintName
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: LINES_MAX_NAME,
                            maxLength: LENGTH_MAX_NAME,
                            onChanged: (_) {
                              setState(() {
                              });
                            },
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
//                            left: spacingHorizontal
                          ),
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
                        Container(
                          child: TextField(
                            controller: textControllerDescription,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
//                                top: spacingVertical,
                                ),
                                hintText: IBLocalString.groupCreateHintDescription
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLength: LENGTH_MAX_DESCRIPTION,
                            maxLines: LINES_MAX_DESCRIPTION,
                            onChanged: (_) {
                              setState(() {
                              });
                            },
                          ),
                          margin: EdgeInsets.only(
                            top: SPACING_VERTICAL,
//                            left: spacingHorizontal
                          ),
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
                  !isEditMode ? Container(
                      child: Text(
                        idsUsersSelected.isEmpty ? IBLocalString.groupCreateNoMembers : IBLocalString.groupCreateMembersCount(idsUsersSelected.length),
                        style: TextStyle(
                            fontSize: 16.0,
                            fontStyle: idsUsersSelected.isEmpty ? FontStyle.italic : FontStyle.normal
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: SPACING_VERTICAL,
                        left: SPACING_HORIZONTAL,
                      )
                  ) : Container(),
                  !isEditMode && idsUsersSelected.isNotEmpty ? Container(
                    child: ListView(
                      children: idsUsersSelected.map((payload) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: IBWidgetUserIcon(
                                    payload.id
                                ),
                                height: SIZE_WIDTH_PAYLOAD,
                              ),
                              Container(
                                child: Text(
                                  payload.name,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                                margin: EdgeInsets.only(
                                    top: SPACING_VERTICAL/2
                                ),
                                width: SIZE_WIDTH_PAYLOAD,
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(
                            left: SPACING_HORIZONTAL/2,
                            right: SPACING_HORIZONTAL/2,
                          ),
                        );
                      }).toList(),
                      scrollDirection: Axis.horizontal,
                    ),
                    height: SIZE_WIDTH_PAYLOAD + 16.0 + SPACING_VERTICAL/2, // font size plus margin
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL/2,
                      right: SPACING_HORIZONTAL/2,
                    ),
                    width: SIZE_WIDTH_PAYLOAD,
                  ) : Container(),
                  !isEditMode ? Container(
                    child: GestureDetector(
                      child: Text(
                        IBLocalString.groupCreateSearchMembers,
                        style: TextStyle(
                            color: taps[IS_TAPPED_SEARCH_USERS] ?? false ? IBColors.logo : Colors.black,
                            fontSize: 16.0
                        ),
                      ),
                      onTapCancel: () {
                        setState(() {
                          taps[IS_TAPPED_SEARCH_USERS] = false;
                        });
                      },
                      onTapDown: (_) {
                        setState(() {
                          taps[IS_TAPPED_SEARCH_USERS] = true;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          taps[IS_TAPPED_SEARCH_USERS] = false;
                        });
                        IBWidgetApp.pushWidget(IBWidgetUserSelect(idsSelected: idsUsersSelected.map((userPayload) => userPayload.id).toList(), onSelect: (payloads) {
                          setState(() {
                            this.idsUsersSelected.addAll(payloads);
                          });
                        }), context);
                      },
                    ),
                    margin: EdgeInsets.only(
                      top: SPACING_VERTICAL,
                      left: SPACING_HORIZONTAL,
                    ),
                  ) : Container(),
                ],
                controller: scrollController,
                shrinkWrap: true,
              ),
            ),
          ],
        )
    );
  }

  create() async {
    if (isEditMode) {
      var groupNameBeforeUpdate = group.name;
      group.name = textControllerName.text.trim();
      group.description = textControllerDescription.text.trim();
      if (groupNameBeforeUpdate != group.name) {
        IBFirestore.addGroupPayload(group);
      }
    }
    else {
      idsUsersSelected.add(IBUserApp.current);
      group = IBFirestoreGroup(textControllerName.text.trim(), textControllerDescription.text.trim(), idsUsersSelected.map((userPayload) => userPayload.id).toList());
    }
    await IBFirestore.addGroup(group);
    Navigator.pop(context);
    if (onCreate != null) {
      onCreate(group);
    }
  }
}