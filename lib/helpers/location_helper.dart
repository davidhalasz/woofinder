import 'package:http/http.dart' as http;
import 'dart:convert';

const GOOGLE_API_KEY = 'YOUR_GOOGLE_API_KEY';

class LocationHelper {
  static String generateLocationPreviewImage({latitude, longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  static Future<String> getCountryStreet(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY');
    final response = await http.get(url);
    final components = json.decode(response.body)['results'][0]
        ['address_components'] as List<dynamic>;
    var city = "";
    var street = "";
    var code = "";
    var address = "";
    components.forEach((c) {
      final List type = c['types'];
      if (type.contains('country')) {
        code += "(" + c['short_name'] + ")";
      }
      if (type.contains("locality")) {
        city += c['long_name'];
      }
      if (type.contains("route")) {
        street += c['long_name'];
      }
    });
    address = code + " " + city + ", " + street;
    return address;
  }
}
