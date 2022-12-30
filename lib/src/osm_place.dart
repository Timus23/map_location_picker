class OSMPlace {
  final String displayName;
  final double lat;
  final double lng;
  final String? icon;

  OSMPlace({
    required this.displayName,
    required this.lat,
    required this.lng,
    this.icon,
  });

  factory OSMPlace.fromJson(Map<String, dynamic> json) {
    return OSMPlace(
      displayName: json["display_name"] ?? "",
      lat: double.parse(json["lat"].toString()),
      lng: double.parse(json["lon"].toString()),
      icon: json["icon"],
    );
  }
}
