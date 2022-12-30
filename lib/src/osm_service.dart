import 'package:dio/dio.dart';
import 'package:map_location_picker/src/osm_place.dart';

class OSMService {
  Future<List<OSMPlace>> searchPlaces(String query) async {
    try {
      final dio = Dio();
      final param = {"format": "json", "q": query};
      final res = await dio.get(
        "https://nominatim.openstreetmap.org/search",
        queryParameters: param,
      );
      final items =
          List.from(res.data).map((e) => OSMPlace.fromJson(e)).toList();
      return items;
    } catch (e) {
      return [];
    }
  }
}
