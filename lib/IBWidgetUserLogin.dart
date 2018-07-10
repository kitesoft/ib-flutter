
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ib/IBUserApp.dart';
import 'package:ib/IBColors.dart';
import 'package:ib/IBDefaults.dart';
import 'package:ib/IBFirestore.dart';
import 'package:ib/IBMessaging.dart';
import 'package:ib/IBLocalString.dart';


typedef void IBCallbackWidgetUserLogin();

class IBWidgetUserLogin extends StatefulWidget {

  final IBCallbackWidgetUserLogin onLogin;

  IBWidgetUserLogin({this.onLogin, Key key}) : super(key: key);

  @override
  IBStateWidgetUserLogin createState() {
    return IBStateWidgetUserLogin(onComplete: onLogin);
  }
}


class IBStateWidgetUserLogin extends State<IBWidgetUserLogin> {

  static const LENGTH_MAX_NAME = 35;
  static const LENGTH_MAX_PASSWORD = 8;

  static const LENGTH_MIN_NAME = 6;
  static const LENGTH_MIN_PASSWORD = 8;

  static const LINES_MAX_NAME = 1;
  static const LINES_MAX_PASSWORD = 1;

  static const SIZE_ICON = 25.0;
  static const SIZE_USER_ICON = 65.0;

  static const SPACING_HORIZONTAL = 8.0;
  static const SPACING_VERTICAL = 6.0;
  static const SPACING_VERTICAL_EDGE = 8.0;

  IBCallbackWidgetUserLogin onComplete;

  IBStateWidgetUserLogin({this.onComplete});

  var fileImage;

  bool get isLoginEnabled {
    return textControllerName.text.length >= LENGTH_MIN_NAME && textControllerPassword.text.length >= LENGTH_MIN_PASSWORD && (inputName != textControllerName.text || inputPassword != textControllerPassword.text);
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
                      left: SPACING_HORIZONTAL/2,
                    ),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              margin: EdgeInsets.only(
                top: SPACING_VERTICAL,
                left: SPACING_HORIZONTAL,
                right: SPACING_HORIZONTAL,
                bottom: SPACING_VERTICAL,
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
                          top: SPACING_VERTICAL,
//                                  right: iconSize/2
                        ),
                        hintText: IBLocalString.userLoginHintName
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
                        color: textControllerName.text.length >= LENGTH_MIN_NAME ? IBColors.logo : Colors.grey,
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
                top: SPACING_VERTICAL_EDGE,
                left: SPACING_HORIZONTAL,
                right: SPACING_HORIZONTAL,
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
                          top: SPACING_VERTICAL,
//                                  right: iconSize/2
                        ),
                        hintText: IBLocalString.userLoginHintPassword
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: LINES_MAX_PASSWORD,
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
            ),
          ],
        )
    );
  }
}