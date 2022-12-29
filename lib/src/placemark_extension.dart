import 'package:map_location_picker/map_location_picker.dart';

extension PlaceMarkExtension on Placemark? {
  String get formatedStreet {
    if (this == null) {
      return "";
    }
    String formatedText = "";
    if (this!.subLocality?.isNotEmpty == true) {
      formatedText += this!.subLocality!;
    } else if (this!.thoroughfare?.isNotEmpty == true) {
      formatedText += this!.thoroughfare!;
    } else if (this!.subThoroughfare?.isNotEmpty == true) {
      formatedText += this!.subThoroughfare!;
    }

    if (this!.subAdministrativeArea?.isNotEmpty == true) {
      formatedText += " ${this!.subAdministrativeArea}";
    } else if (this!.administrativeArea?.isNotEmpty == true) {
      formatedText += " ${this!.administrativeArea}";
    }

    if (this!.postalCode?.isNotEmpty == true) {
      formatedText += ", ${this!.postalCode}";
    }
    return formatedText;
  }
}
