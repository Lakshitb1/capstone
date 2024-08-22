import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MapServices {
  GoogleMapController? controller;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  LatLng? startLocation;
  LatLng? destLocation;
  List<AccelerometerEvent> accelerometerValues = [];
  String address = "";

  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> startMap() async {
    accelerometerSubscription = accelerometerEvents.listen((event) {
      accelerometerValues = [event];
    });

    Position position = await determinePosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    startLocation = LatLng(position.latitude, position.longitude);
    address =
        "${place.name}, ${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

    if (controller != null) {
      controller!.animateCamera(CameraUpdate.newLatLng(startLocation!));
    }
  }

  void stopMap() {
    startLocation = null;
    destLocation = null;
    address = "";
    accelerometerSubscription?.cancel();
    if (controller != null) {
      controller!.animateCamera(
        CameraUpdate.newLatLng(const LatLng(28.6139, 77.2090)),
      );
    }
  }

  void setDestination(double? latitude, double? longitude) {
    if (latitude != null && longitude != null) {
      destLocation = LatLng(latitude, longitude);
      if (controller != null) {
        controller!.animateCamera(CameraUpdate.newLatLng(destLocation!));
      }
    } else {
      throw Exception('Invalid coordinates.');
    }
  }

  Set<Marker> createMarkers() {
    final markers = <Marker>{};
    if (startLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('startLocation'),
          icon: BitmapDescriptor.defaultMarker,
          position: startLocation!,
        ),
      );
    }
    if (destLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destLocation'),
          icon: BitmapDescriptor.defaultMarker,
          position: destLocation!,
        ),
      );
    }

    return markers;
  }
}
