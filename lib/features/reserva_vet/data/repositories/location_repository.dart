import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationRepository {
  Future<LocationModel> getCurrentLocation() async {
    // Verifica el permiso de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }

    // Verifica si los permisos son permanentes
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación son permanentes.');
    }

    // Obtiene la ubicación actual
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LocationModel(latitude: position.latitude, longitude: position.longitude);
  }
}
