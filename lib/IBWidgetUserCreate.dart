
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDefaults.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBFirestoreUser.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';
import 'package:ib/IBStorage.dart';

import 'package:ib/IBWidgetApp.dart';
import 'package:ib/IBWidgetUserIcon.dart';
import 'package:ib/IBWidgetUserLogin.dart';

typedef void IBCallbackWidgetUserCreate();

class IBWidgetUserCreate extends StatefulWidget {

  final IBCallbackWidgetUserCreate onCreate;
  final IBCallbackWidgetUserCreate onLogin;

  IBWidgetUserCreate({this.onCreate, this.onLogin, Key key}) : super(key: key);

  @override
  IBStateWidgetUserCreate createState() {
    return IBStateWidgetUserCreate(onCreate: onCreate, onLogin: onLogin);
  }
}

class IBStateWidgetUserCreate extends State<IBWidgetUserCreate> {

  static const LENGTH_MAX_DESCRIPTION = 150;
  static const LENGTH_MAX_NAME = 35;

  static const LENGTH_MIN_DESCRIPTION = 10;
  static const LENGTH_MIN_NAME = 6;
  static const LENGTH_MIN_PASSWORD = 8;

  static const LINES_MAX_DESCRIPTION = 3;
  static const LINES_MAX_NAME = 1;
  static const LINES_MAX_PASSWORD = 1;

  static const SIZE_ICON = 25.0;
  static const SIZE_USER_ICON = 65.0;

  static const SPACING_HORIZONTAL = 8.0;
  static const SPACING_VERTICAL = 6.0;
  static const SPACING_VERTICAL_EDGE = 8.0;

  IBCallbackWidgetUserCreate onCreate;
  IBCallbackWidgetUserCreate onLogin;

  IBStateWidgetUserCreate({this.onCreate, this.onLogin});

  var fileImage;

  bool get isCreateEnabled {
    return (fileImage != null || isEditMode) && textControllerName.text.trim().length >= LENGTH_MIN_NAME && textControllerDescription.text.trim().length >= LENGTH_MIN_DESCRIPTION && textControllerPassword.text.length >= LENGTH_MIN_PASSWORD;
  }

  var isCreating = false;

  bool get isEditEnabled {
    return fileImage != null || user.name != textControllerName.text.trim() || user.description != textControllerDescription.text.trim();
  }

  bool get isEditMode {
    return user != null;
  }

  var isTappedIcon = false;
  var isTappedLogin = false;

  var textControllerDescription = TextEditingController();
  var textControllerName = TextEditingController();
  var textControllerPassword = TextEditingController();

  IBFirestoreUser get user {
    return IBUserApp.current;
  }


  @override
  void initState() {

    super.initState();

    // IMPORTANT: determine locale
    IBLocalString.context = context;

    if (user != null) {
      textControllerName.text = user.name;
      textControllerDescription.text = user.description;
      textControllerPassword.text = user.password;
    }

    setupAsync();
  }


  setupAsync() async { }

  Future getImage() async {

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      this.fileImage = image;
    });
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
                        isEditMode ? IBLocalString.userCreateEdit : IBLocalString.userCreate,
                        style: TextStyle(
                            color: isCreateEnabled && (!isEditMode || isEditEnabled) ? isTappedIcon ? IBColors.tappedDownLight : Colors.white : IBColors.actionDisable,
                            fontSize: Theme.of(context).textTheme.title.fontSize,
                            fontWeight: Theme.of(context).textTheme.title.fontWeight
                        ),
                      ),
                      margin: EdgeInsets.only(
                          right: SPACING_HORIZONTAL
                      ),
                    )
                ),
                onTapCancel: () {
                  setState(() {
                    isTappedIcon = false;
                  });
                },
                onTapDown: (_) {
                  setState(() {
                    isTappedIcon = true;
                  });
                },
                onTapUp: (_) async {
                  if (isCreateEnabled && (!isEditMode || isEditEnabled) && !isCreating) {
                    isCreating = true;
                    create();
                  }
                }
            )
          ],
          centerTitle: false,
          elevation: 1.0,
          title: Text(
            user != null ? user.name : IBLocalString.userCreateTitle,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            onCreate != null || onLogin != null ? Container(
              child: Center(
                child: Text(
                  IBLocalString.userCreateCreate,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              color: IBColors.logo80,
              padding: EdgeInsets.only(
                  top: SPACING_VERTICAL,
                  left: SPACING_HORIZONTAL,
                  right: SPACING_HORIZONTAL,
                  bottom: SPACING_VERTICAL
              ),
            ) : Container(),
            !isEditMode ? GestureDetector(
              child: Container(
                child: Center(
                  child: Text(
                    IBLocalString.userCreateLogin,
                    style: TextStyle(
                      color: isTappedLogin ? IBColors.tappedDown: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: SPACING_VERTICAL,
                    left: SPACING_HORIZONTAL,
                    right: SPACING_HORIZONTAL,
                    bottom: SPACING_VERTICAL
                ),
              ),
              onTapCancel: () {
                setState(() {
                  isTappedLogin = false;
                });
              },
              onTapDown: (_) {
                setState(() {
                  isTappedLogin = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  isTappedLogin = false;
                });
                IBWidgetApp.pushWidget(IBWidgetUserLogin(onLogin: () {
                  Navigator.pop(context);
                  if (onLogin != null) {
                    onLogin();
                  }
                }), context);
              },
            ) : Container(),
            GestureDetector(
              child: Container(
                child: Center(
                  child: fileImage != null ? AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipOval(
                      child: Image.file(
                        fileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ) : user != null ? IBWidgetUserIcon(
                    user.id,
                  ) : Icon(
                    Icons.add_a_photo,
                    color: Colors.black26,
                    size: SIZE_USER_ICON,
                  ),
                ),
                height: SIZE_USER_ICON,
                margin: EdgeInsets.only(
                    top: SPACING_VERTICAL_EDGE
                ),
                width: SIZE_USER_ICON,
              ),
              onTapUp: (_) {
                getImage();
              },
            ),
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
                        hintText: IBLocalString.userCreateHintName
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: LINES_MAX_NAME,
                    maxLength: LENGTH_MAX_NAME,
                    onChanged: (_) {
                      setState(() { });
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
                        hintText: IBLocalString.userCreateHintDescription
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: LINES_MAX_DESCRIPTION,
                    maxLength: LENGTH_MAX_DESCRIPTION,
                    onChanged: (_) {
                      setState(() { });
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
            !isEditMode ? Container(
              child: Stack(
                children: <Widget>[
                  TextField(
                    controller: textControllerPassword,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          top: SPACING_VERTICAL,
//                                  right: iconSize/2
                        ),
                        hintText: IBLocalString.userCreateHintPassword
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: LINES_MAX_PASSWORD,
                    obscureText: true,
                    onChanged: (_) {
                      setState(() { });
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      child: Icon(
                        Icons.done,
                        color: textControllerPassword.text.length >= LENGTH_MIN_PASSWORD ? IBColors.logo : Colors.grey,
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
                bottom: SPACING_VERTICAL_EDGE,
              ),
            ) : Container(),
          ],
        )
    );
  }


  create() async {
    if (isEditMode) {
      var userNameBeforeUpdate = user.name;
      IBUserApp.current.name = textControllerName.text.trim();
      IBUserApp.current.description = textControllerDescription.text.trim();
      if (userNameBeforeUpdate != IBUserApp.current.name) {
        IBFirestore.addUserAppPayload();
      }
    }
    else {
      var token = await IBMessaging.getToken();
      var user = IBFirestoreUser(textControllerName.text.trim(), textControllerDescription.text.trim(), IBLocalString.codeLanguage, textControllerPassword.text, token);
      IBUserApp.current = user;
    }
    await IBFirestore.addUserApp();
    if (fileImage != null) {
      await IBStorage.upload(fileImage, IBUserApp.current.id);
    }
    await IBDefaults.setIdUser(IBUserApp.current.id);
    Navigator.pop(context);
    if (onCreate != null) {
      onCreate();
    }
  }
}