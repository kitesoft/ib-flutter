

class GoogleAddressComponent {

  List<String> types;
  String shortName;
  String longName;

  GoogleAddressComponent.firestore({String shortName, String type}) {
    this.shortName = shortName;
    this.types = List<String>();
    this.types.add(type);
  }

  GoogleAddressComponent.geocode(Map map) {
    types = List<String>();
    map["types"].forEach((type) => types.add(type));
    shortName = map["short_name"];
    longName = map["long_name"];
  }

  bool get isCity {
    return types.contains("locality") ||  types.contains("city") || types.contains("administrative_area_level_2");
  }

  bool get isCountry {
    return types.contains("country");
  }
}

class GooglePlace {

  String id;

  String name;
  String description;

  String address;
  var addressComponents =  List<GoogleAddressComponent>();

  double lat;
  double lon;

  var types = List<String>();

  GoogleAddressComponent get cityComponent {
    return addressComponents.firstWhere((component) => component.isCity);
  }

  bool get isLocality {
    return types.contains("locality");
  }

  bool get isCity {
    return isLocality ||  types.contains("city") || types.contains("administrative_area_level_2");
  }

  GooglePlace.geocode(Map map) {
    id = map["place_id"];
    address = map["formatted_address"];
    lat = map["geometry"]["location"]["lat"];
    lon = map["geometry"]["location"]["lng"];
    map["types"].forEach((type) => types.add(type));
    map["address_components"].forEach((component) => addressComponents.add(GoogleAddressComponent.geocode(component)));
  }

  GooglePlace.autocompletion(Map map) {
    id = map["place_id"];
    name = map["structured_formatting"]["main_text"];
    description = map["description"];
    map["types"].forEach((type) => types.add(type));
  }

  addGeocode(Map map) {
    address = map["formatted_address"];
    addressComponents = List<GoogleAddressComponent>();
    lat = map["geometry"]["location"]["lat"];
    lon = map["geometry"]["location"]["lng"];
    map["types"].forEach((type) => types.add(type));
    map["address_components"].forEach((component) => addressComponents.add(GoogleAddressComponent.geocode(component)));
  }
}