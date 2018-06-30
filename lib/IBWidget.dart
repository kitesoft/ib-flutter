
import 'package:flutter/material.dart';

class IBWidget {

  static double divisorHeight = 0.5;

  static defaultAppBar(String title) {
    new AppBar(
        centerTitle: false,
        iconTheme: new IconThemeData(
            color: Colors.white
        ), title:
    new Text(
        title,
        style: new TextStyle(
            color: Colors.white
        )
    )
    );
  }
}