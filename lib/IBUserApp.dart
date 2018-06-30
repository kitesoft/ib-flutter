
import 'IBFirestoreUser.dart';

class IBUserApp {

  static IBFirestoreUser current;

  static String get currentId {
    if (current != null) {
      return current.id;
    }
    return "-1";
  }
}