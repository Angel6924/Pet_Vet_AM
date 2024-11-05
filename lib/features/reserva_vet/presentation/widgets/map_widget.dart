import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/location_repository.dart';
import 'package:reserva_pet_vet/features/reserva_vet/domain/uses_cases/get_current_location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  MapWidgetState createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  GoogleMapController? mapController;
  LatLng initialLocation =LatLng(-12.008227499733348, -77.0924429745174);
  final Set<Marker> _markers = {};
  final LocationRepository locationRepository = LocationRepository();
  final GetCurrentLocation getCurrentLocation = GetCurrentLocation(LocationRepository());

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
  try {
    final locationEntity = await getCurrentLocation.call();
    LatLng currentLocation = LatLng(locationEntity.latitude, locationEntity.longitude);
    if (mounted) {
      mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

  void _addMarker() {
    LatLng targetLocation = LatLng(-11.962814488546648, -77.07206437908384);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('destination_marker'),
        position: targetLocation,
        infoWindow: InfoWindow(title: 'Destino', snippet: 'Aquí es donde quieres ir'),
      ));
      mapController?.animateCamera(CameraUpdate.newLatLng(targetLocation)); // Mueve la cámara al destino
    });
  }

  void _openGoogleMaps() async {
  final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps?q=-11.962814488546648,-77.07206437908384');
  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl);
  } else {
    throw 'No se pudo abrir Google Maps';
  }
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLocation,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            mapController = controller;
          },
          markers: _markers,
        ),
        Positioned(
          top: 200, // Ajusta esta posición según sea necesario
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                height: 140, // Altura del primer contenedor
                color: Colors.cyan, // Color celeste
              ),
              Container(
                height: 210, // Altura del segundo contenedor
                color: Colors.white, // Color blanco
              ),
            ],
          ),
        ),
        Positioned(
          top: 100, // Ajusta esta posición según sea necesario
          right: 5, // Ajusta esta posición según sea necesario
          child: IconButton(
            icon: Icon(Icons.location_on, color: Colors.red, size: 30), // Ícono para agregar marcador
            onPressed: _addMarker,
          ),
        ),
        Positioned(
          top: 50, // Ajusta esta posición según sea necesario
          right: 5, // Ajusta esta posición según sea necesario
          child: IconButton(
            icon: Icon(Icons.open_in_new, color: Colors.black, size: 30), // Ícono para abrir Google Maps
            onPressed: _openGoogleMaps,
          ),
        ),
      ],
    );
  }
}
