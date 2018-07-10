
import 'package:ib/IBFirestoreEvent.dart';


class IBFirestoreCacheEvents {

  List<IBFirestoreEvent> events;

  String idGroup;
  String idPlace;
  String idUserCreator;
  String idUserFollower;

  bool isActive;
  String typePlace;

  bool didLoadIndexed;

  IBFirestoreCacheEvents({this.didLoadIndexed, this.events, this.idGroup, this.idPlace, this.typePlace, this.idUserCreator, this.idUserFollower, this.isActive});
}