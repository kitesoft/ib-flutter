
import 'package:flutter/material.dart';

import 'package:ib/IBColors.dart';

typedef void IBWidgetTapTextCallback();

class IBWidgetTapText extends StatefulWidget {

  final String data;

  final IBWidgetTapTextCallback onTap;
  final bool isEnabledOnTap;

  final TextStyle style;
  final TextAlign textAlign;

  IBWidgetTapText(this.data, {this.onTap, this.isEnabledOnTap = true, this.style = const TextStyle(), this.textAlign});

  @override
  State<StatefulWidget> createState() {
    return IBStateWidgetTapText(data, onTap: onTap, onTapEnabled: isEnabledOnTap, style: style, textAlign: textAlign);
  }
}

class IBStateWidgetTapText extends State<IBWidgetTapText> {

  String data;

  IBWidgetTapTextCallback onTap;
  bool onTapEnabled;

  var style = TextStyle();
  var textAlign = TextAlign.left;

  IBStateWidgetTapText(this.data, {this.onTap, this.onTapEnabled, this.style, this.textAlign});

  var tappedDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        data,
        style: TextStyle(
          color: !tappedDown ? Colors.black : IBColors.logo,
          fontSize: style.fontSize,
          fontStyle: style.fontStyle,
          fontWeight: style.fontWeight,
        ),
        textAlign: textAlign,
      ),
      onTapCancel: () {
        if (onTapEnabled) {
          setState(() {
            tappedDown = false;
          });
        }
      },
      onTapDown: (_) {
        if (onTapEnabled) {
          setState(() {
            tappedDown = true;
          });
        }
      },
      onTapUp: (_) {
        if (onTapEnabled) {
          setState(() {
            tappedDown = false;
          });
          onTap();
        }
      },
    );
  }
}