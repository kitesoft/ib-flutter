
import 'package:ib/IBFirestore.dart';

class IBFirestoreGroup {

  operator ==(Object o) => o is IBFirestoreGroup && id == o.id;
  int get hashCode => id.hashCode;

  String id;
  String name;
  String description;

  List<String> idsMembers;

  IBFirestoreGroup(this.name, this.description, this.idsMembers);

  IBFirestoreGroup.firestore(this.id, Map data) {

    name = data[IBFirestore.NAME];
    description = data[IBFirestore.DESCRIPTION];

    idsMembers = List<String>();
    (data[IBFirestore.IDS_MEMBERS] ?? Map()).entries.where((entry) => entry.value == true).forEach((entry) {
      idsMembers.add(entry.key);
    });
  }

  Map<String, dynamic> get map {
    var map = {
      IBFirestore.NAME : name,
      IBFirestore.DESCRIPTION : description,
      IBFirestore.IDS_MEMBERS : idsMembers.asMap().map((_, id) => MapEntry(id, true)),
    };
    return map;
  }

  Map<String, dynamic> get mapPayload {
    var map = {
      IBFirestore.NAME : name,
    };
    return map;
  }
}












