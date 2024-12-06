import 'dart:async';
import 'package:cap_1/models/user.dart';
import 'package:cap_1/providers/user_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapServices {
  GoogleMapController? controller;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  LatLng? startLocation;
  LatLng? destLocation;
  List<AccelerometerEvent> accelerometerValues = [];
  String address = "";
  String prediction = "Unknown";
  List<Map<String, dynamic>> dataRecords = [];

  // Determine the user's current position
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

  // Start the map and accelerometer tracking
 Future<void> startMap(BuildContext context) async {
  // Get the user's current location
  Position position = await determinePosition();
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks[0];
  startLocation = LatLng(position.latitude, position.longitude);
  address =
      "${place.name}, ${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

  // Update map camera
  if (controller != null) {
    controller!.animateCamera(CameraUpdate.newLatLng(startLocation!));
  }

  // Store initial accelerometer values
  List<double>? initialValues;

  accelerometerSubscription = accelerometerEventStream().listen((event) {
    if (initialValues == null) {
      // Set initial accelerometer values
      initialValues = [event.x, event.y, event.z];
    } else {
      // Calculate the difference between current and initial values
      double deltaX = (event.x - initialValues![0]).abs();
      double deltaY = (event.y - initialValues![1]).abs();
      double deltaZ = (event.z - initialValues![2]).abs();

      // Check if any difference exceeds 0.5
      if (deltaX > 0.5 || deltaY > 0.5 || deltaZ > 0.5) {
        // Update initial values to the current values
        initialValues = [event.x, event.y, event.z];

        // Call the prediction API
        sendDataForPrediction(event, context);
      }
    }
  });
}

  // Send accelerometer data for prediction
  Future<void> sendDataForPrediction(
      AccelerometerEvent event, BuildContext context) async {
    final data = {
      'x': event.x,
      'y': event.y,
      'z': event.z,
    };

    try {
      var url = Uri.parse('http://192.168.183.207:5002/predict');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String predictedLabel = responseData['label'];
        prediction = predictedLabel;
        Provider.of<UserProvider>(context, listen: false)
            .setPrediction(predictedLabel);

        // Save data only if the prediction is "bump" or "pothole"
        if (predictedLabel == 'bump' || predictedLabel == 'pothole') {
          dataRecords.add({
            'x': event.x,
            'y': event.y,
            'z': event.z,
            'label': predictedLabel,
          });
        }
      } else {
        throw Exception('Failed to get prediction');
      }
    } catch (e) {
      print('Error during prediction: $e');
    }
  }

  // Stop the map and upload accelerometer data as CSV
  void stopMap(BuildContext context) async {
    startLocation = null;
    destLocation = null;
    address = "";
    prediction = "Unknown";

    accelerometerSubscription?.cancel();
    accelerometerSubscription = null; 
    // Stop accelerometer subscription
    if (controller != null) {
      controller!.animateCamera(
        CameraUpdate.newLatLng(
            const LatLng(28.6139, 77.2090)), // Default location
      );
    }

    if (dataRecords.isNotEmpty) {
      try {
        // Convert records to CSV
        List<List<dynamic>> csvData = [
          ['x', 'y', 'z', 'label'],
          ...dataRecords.map((record) =>
              [record['x'], record['y'], record['z'], record['label']]),
        ];
        String csvString = const ListToCsvConverter().convert(csvData);
        print(csvString);

        // Upload the CSV
        String token =
            Provider.of<UserProvider>(context, listen: false).user.token;

        var url = Uri.parse('http://192.168.183.207:5002/upload_csv');
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
          body: json.encode({'csv_data': csvString}),
        );

        if (response.statusCode == 200) {
          print('CSV uploaded successfully');
          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("CSV uploaded successfully")),
          );
        } else {
          print('Error uploading CSV: ${response.body}');
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading CSV: ${response.body}")),
          );
        }
      } catch (e) {
        print('Error during CSV upload: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during CSV upload: $e")),
        );
      }
    }

    // Clear stored records
    dataRecords.clear();
  }

  // Set destination coordinates
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

  // Create map markers
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
