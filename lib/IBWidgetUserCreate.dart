
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

typedef void IBWidgetUserCreateCompletion();

class IBWidgetUserCreate extends StatefulWidget {

  final IBWidgetUserCreateCompletion onComplete;

  IBWidgetUserCreate({this.onComplete, Key key}) : super(key: key);

  @override
  IBStateWidgetUserCreate createState() {
    return IBStateWidgetUserCreate(onComplete: onComplete);
  }
}

class IBStateWidgetUserCreate extends State<IBWidgetUserCreate> {

  static int lengthMaxDescription = 150;
  static int lengthMaxName = 35;
  static int lengthMaxPassword;

  static int lengthMinDescription = 10;
  static int lengthMinName = 6;
  static int lengthMinPassword = 8;

  static int linesMaxDescription = 3;
  static int linesMaxName = 1;
  static int linesMaxPassword = 1;

  static double sizeIcon = 25.0;
  static double sizeUserIcon = 65.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBWidgetUserCreateCompletion onComplete;

  IBStateWidgetUserCreate({this.onComplete});

  var fileImage;

  bool get isCreateEnabled {
    return (fileImage != null || isEditMode) && textControllerName.text.trim().length >= lengthMinName && textControllerDescription.text.trim().length >= lengthMinDescription && textControllerPassword.text.length >= lengthMinPassword;
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
                            color: isCreateEnabled && (!isEditMode || isEditEnabled) ? isTappedIcon ? IBColors.actionTappedDown : Colors.white : IBColors.actionDisable,
                            fontSize: Theme.of(context).textTheme.title.fontSize,
                            fontWeight: Theme.of(context).textTheme.title.fontWeight
                        ),
                      ),
                      margin: EdgeInsets.only(
                          right: spacingHorizontal
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
                    createUser();
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
            onComplete != null ? Container(
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
                  top: spacingVertical,
                  left: spacingHorizontal,
                  right: spacingHorizontal,
                  bottom: spacingVertical
              ),
            ) : Container(),
            !isEditMode ? GestureDetector(
              child: Container(
                child: Center(
                  child: Text(
                    IBLocalString.userCreateLogin,
                    style: TextStyle(
                      color: isTappedLogin ? IBColors.logo : Colors.black,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: spacingVertical,
                    left: spacingHorizontal,
                    right: spacingHorizontal,
                    bottom: spacingVertical
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
                IBWidgetApp.pushWidget(IBWidgetUserLogin(onComplete: () {
                  Navigator.pop(context);
                  if (onComplete != null) {
                    onComplete();
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
                    size: sizeUserIcon,
                  ),
                ),
                height: sizeUserIcon,
                margin: EdgeInsets.only(
                    top: spacingVerticalEdge
                ),
                width: sizeUserIcon,
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
                          top: spacingVertical,
//                                  right: iconSize/2
                        ),
                        hintText: IBLocalString.userCreateHintName
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: linesMaxName,
                    maxLength: lengthMaxName,
                    onChanged: (_) {
                      setState(() { });
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
                        hintText: IBLocalString.userCreateHintDescription
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: linesMaxDescription,
                    maxLength: lengthMaxDescription,
                    onChanged: (_) {
                      setState(() { });
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
            !isEditMode ? Container(
              child: Stack(
                children: <Widget>[
                  TextField(
                    controller: textControllerPassword,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          top: spacingVertical,
//                                  right: iconSize/2
                        ),
                        hintText: IBLocalString.userCreateHintPassword
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: linesMaxPassword,
                    maxLength: lengthMaxPassword,
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
                        color: textControllerPassword.text.length >= lengthMinPassword ? IBColors.logo : Colors.grey,
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
                bottom: spacingVerticalEdge,
              ),
            ) : Container(),
          ],
        )
    );
  }


  createUser() async {
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
    if (onComplete != null) {
      onComplete();
    }
  }
}