import '../entities/location_entity.dart';
import 'package:reserva_pet_vet/features/reserva_vet/data/repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  Future<LocationEntity> call() async {
    final locationModel = await repository.getCurrentLocation();
    return LocationEntity(latitude: locationModel.latitude, longitude: locationModel.longitude);
  }
}
