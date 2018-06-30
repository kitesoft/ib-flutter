
import 'package:flutter/material.dart';

import 'package:ib/IBStorage.dart';

class IBWidgetUserIcon extends StatefulWidget {

  final String id;

  IBWidgetUserIcon(this.id, {Key key}) : super(key: key);

  @override
  IBStateWidgetUserIcon createState() {
    return IBStateWidgetUserIcon(this.id);
  }
}

class IBStateWidgetUserIcon extends State<IBWidgetUserIcon> {

  String id;

  IBStateWidgetUserIcon(this.id);

  String downloadUrl;

  var downloadUrls = Map<String, String>();

  @override
  void initState() {
    super.initState();
    setupAsync();
  }

  setupAsync() async {
    if (id != null) {
      if (!downloadUrls.containsKey(id)) {
        var downloadUrl = await IBStorage.getDownloadUrl(id);
        downloadUrls[id] = downloadUrl;
        if (mounted) {
          setState(() {
            this.downloadUrl = downloadUrl;
          });
        }
      }
      else {
        setState(() {
          this.downloadUrl = downloadUrls[id];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: downloadUrl != null ? ClipOval(
        child: Image.network(
          downloadUrl,
          fit: BoxFit.cover,
        ),
      ) : Container(),
    );
  }
}
