import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Los permisos de ubicación son permanentes.'); 
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}

class ReservaPage extends StatefulWidget {
  const ReservaPage({super.key});

  @override
  ReservaPageState createState() => ReservaPageState();
}

class ReservaPageState extends State<ReservaPage> {
  int selectedIndex = -1;
  bool isRouteVisible = false;
  bool cont1Visible = true;
  GoogleMapController? mapController;
  LatLng targetLocation = LatLng(-11.962814488546648, -77.07206437908384);
  LatLng initialLocation = LatLng(-12.008227499733348, -77.0924429745174);
  LatLng? currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation!));
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $error')),
      );
    }
  }

  Future<void> _toggleRoute() async {
    if (isRouteVisible) {
      // Si la ruta está visible, la elimina
      setState(() {
        _polylines.clear();
        isRouteVisible = false;
      });
    } else {
      // Si la ruta no está visible, la dibuja
      await _drawRoute();
      setState(() {
        isRouteVisible = true;
      });
    }
  }

  void _toggleContainer() {
    setState(() {
      cont1Visible = !cont1Visible;
    });
  }

  Future<void> _drawRoute() async {
    if (currentLocation == null) return;

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation!.latitude},${currentLocation!.longitude}&destination=${targetLocation.latitude},${targetLocation.longitude}&key=AIzaSyCTOcYo3BZAG1TE7Swi7Y38ReLUfnxBwvk';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> routePoints = [];

        // Extrae los puntos de la ruta
        var steps = data['routes'][0]['legs'][0]['steps'];
        for (var step in steps) {
          routePoints.add(LatLng(
            step['start_location']['lat'],
            step['start_location']['lng'],
          ));
          routePoints.add(LatLng(
            step['end_location']['lat'],
            step['end_location']['lng'],
          ));
        }

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: routePoints,
              color: Colors.purple,
              width: 5,
            ),
          );
        });
      } else {
        print("Error al obtener la ruta: ${data['status']}");
      }
    } else {
      print("Error en la solicitud: ${response.statusCode}");
    }
  }
  

  void _addMarker() {
    LatLng targetLocation = LatLng(-11.962814488546648, -77.07206437908384);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('destination_marker'),
        position: targetLocation,
        infoWindow:
            InfoWindow(title: 'Destino', snippet: 'Aquí es donde quieres ir'),
      ));
      mapController?.animateCamera(CameraUpdate.newLatLng(targetLocation));
    });
  }

  void _addUbication() {
    if (currentLocation != null) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('current_location_marker'),
          position: currentLocation!,
          infoWindow: InfoWindow(
              title: 'Tu Ubicación Actual', snippet: 'Aquí estás ahora'),
        ));
        mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation!));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la ubicación actual')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.32,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: initialLocation, zoom: 15),
                onMapCreated: (controller) => mapController = controller,
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          // Contenedor1
          if (cont1Visible)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.32,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.19,
                color: Color(0xFF51C2FF).withOpacity(0.16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenido al apartado de Reservas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Elija un servicio al que desees acceder para\npoder crear una cita con nuestros equipos\nde trabajo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Contenedor 2
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: cont1Visible
                ? MediaQuery.of(context).size.height * 0.51
                : MediaQuery.of(context).size.height * 0.32,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: cont1Visible
                  ? MediaQuery.of(context).size.height * 0.38
                  : MediaQuery.of(context).size.height * 0.57,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.5),
                    child: IconButton(
                      icon: Icon(Icons.expand_more,
                          color: Colors.black, size: 24),
                      onPressed: _toggleContainer,
                    ),
                  ),
                  SizedBox(height: 0.5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\t\t\t\t¿Qué servicio deseas reservar?',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13
                      , color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 3.5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\t\t\t\t¡Hola,  @User!',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 11, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 12),
                  
                   

                  SizedBox(height: 14),
                  Positioned(  
                      left: 2,
                      right: 2,
                        child: Container(
                            height: 35,
                            width: MediaQuery.of(context).size.height * 0.42,
                          decoration: BoxDecoration(
                            color: Color(0xFF51C2FF).withOpacity(0.16),
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: 275,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.location_searching,
                    color: Colors.black, size: 20),
                onPressed: _drawRoute,
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 275,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.location_on, color: Colors.black, size: 20),
                onPressed: _addMarker,
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: 12,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.black, size: 20),
                onPressed: _toggleRoute,
              ),
            ),
          ),
          Positioned(
            top: 110,
            right: 275,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.location_searching,
                    color: Colors.black, size: 20),
                onPressed: _addUbication,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
