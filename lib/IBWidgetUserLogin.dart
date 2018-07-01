
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDefaults.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';


typedef void IBWidgetUserCallback();

class IBWidgetUserLogin extends StatefulWidget {

  final IBWidgetUserCallback onComplete;

  IBWidgetUserLogin({this.onComplete, Key key}) : super(key: key);

  @override
  IBStateWidgetUserLogin createState() {
    return IBStateWidgetUserLogin(onComplete: onComplete);
  }
}


class IBStateWidgetUserLogin extends State<IBWidgetUserLogin> {

  static int lengthMaxName = 35;
  static int lengthMaxPassword;

  static int lengthMinName = 6;
  static int lengthMinPassword = 8;

  static int linesMaxName = 1;
  static int linesMaxPassword = 1;

  static double sizeIcon = 25.0;
  static double sizeUserIcon = 65.0;

  static double spacingHorizontal = 8.0;
  static double spacingVertical = 6.0;
  static double spacingVerticalEdge = 8.0;

  IBWidgetUserCallback onComplete;

  IBStateWidgetUserLogin({this.onComplete});

  var fileImage;

  bool get isLoginEnabled {
    return textControllerName.text.length >= lengthMinName && textControllerPassword.text.length >= lengthMinPassword && (inputName != textControllerName.text || inputPassword != textControllerPassword.text);
  }

  String inputName;
  String inputPassword;

  var isInputIncorrect = false;
  var isTappedIcon = false;
  var isTappedLogin = false;

  var textControllerName = TextEditingController();
  var textControllerPassword = TextEditingController();


  @override
  void initState() {

    super.initState();

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
                        IBLocalString.userLogin,
                        style: TextStyle(
                            color: isLoginEnabled ? isTappedIcon ? IBColors.tappedDownLight : Colors.white : IBColors.actionDisable,
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

                  if (isLoginEnabled) {

                    inputName = textControllerName.text;
                    inputPassword = textControllerPassword.text;

                    var user = await IBFirestore.getUserLogin(textControllerName.text, textControllerPassword.text);

                    if (user != null) {

                      IBUserApp.current = user;
                      await IBDefaults.setIdUser(IBUserApp.current.id);
                      if (onComplete != null) {
                        Navigator.pop(context);
                        onComplete();
                      }

                      var token = await IBMessaging.getToken();
                      var defaultToken = await IBDefaults.getToken();

                      if (token != defaultToken) {
                        IBDefaults.setToken(token);
                        IBUserApp.current.token = token;
                        IBFirestore.addUserAppPayload();
                      }
                    }
                    else {
                      setState(() {
                        isInputIncorrect = true;
                        isTappedIcon = false;
                      });
                    }
                  }
                }
            )
          ],
          centerTitle: false,
          elevation: 1.0,
          title: Text(
            IBLocalString.userLoginTitle,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            isInputIncorrect ? Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        IBLocalString.userLoginInputIncorrect,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: spacingHorizontal/2,
                    ),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              margin: EdgeInsets.only(
                top: spacingVertical,
                left: spacingHorizontal,
                right: spacingHorizontal,
                bottom: spacingVertical,
              ),
            ) : Container(),
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
                        hintText: IBLocalString.userLoginHintName
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
                        color: textControllerName.text.length >= lengthMinName ? IBColors.logo : Colors.grey,
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
                top: spacingVerticalEdge,
                left: spacingHorizontal,
                right: spacingHorizontal,
              ),
            ),
            Container(
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
                        hintText: IBLocalString.userLoginHintPassword
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: linesMaxPassword,
                    maxLength: lengthMaxPassword,
                    obscureText: true,
                    onChanged: (_) {
                      setState(() {  });
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
            ),
          ],
        )
    );
  }
}