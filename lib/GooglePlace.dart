

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
  List<String> types;

  String name;
  String description;

  String address;

  double lat;
  double lon;

  List<GoogleAddressComponent> addressComponents;

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
    types = List<String>();
    map["types"].forEach((type) => types.add(type));
    addressComponents = List<GoogleAddressComponent>();
    map["address_components"].forEach((component) => addressComponents.add(GoogleAddressComponent.geocode(component)));
  }

  GooglePlace.autocompletion(Map map) {
    id = map["place_id"];
    types = List<String>();
    map["types"].forEach((type) => types.add(type));
    name = map["structured_formatting"]["main_text"];
    description = map["description"];
  }

  addGeocode(Map geocode) {
    address = geocode["formatted_address"];
    lat = geocode["geometry"]["location"]["lat"];
    lon = geocode["geometry"]["location"]["lng"];
    types = List<String>();
    geocode["types"].forEach((type) => types.add(type));
    addressComponents = List<GoogleAddressComponent>();
    geocode["address_components"].forEach((component) => addressComponents.add(GoogleAddressComponent.geocode(component)));
  }
}