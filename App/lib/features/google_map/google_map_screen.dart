import 'package:cap_1/common/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapPageState();
}

class _MapPageState extends State<MapScreen> {
  late GoogleMapController _controller;
  bool _isMapStarted = false;
  final locationController = Location();

  LatLng? startLocation;
  LatLng? destLocation;

  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) return;
    }
    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    locationController.onLocationChanged.listen((liveLocation) {
      if (liveLocation.latitude != null && liveLocation.longitude != null) {
        setState(() {
          startLocation =
              LatLng(liveLocation.latitude!, liveLocation.longitude!);
          _controller.animateCamera(CameraUpdate.newLatLng(startLocation!));
        });
      }
    });
  }

  void _startMap() {
    setState(() {
      _isMapStarted = true;
      startLocation = null;
      destLocation = null;
    });
    fetchLocationUpdates();
  }

  void _stopMap() {
    setState(() {
      _isMapStarted = false;
      startLocation = null;
      destLocation = null;
    });
  }

  void _setDestination() {
    final double? latitude = double.tryParse(_latitudeController.text);
    final double? longitude = double.tryParse(_longitudeController.text);
    if (latitude != null && longitude != null) {
      setState(() {
        destLocation = LatLng(latitude, longitude);
      });
      if (_controller != null) {
        _controller.animateCamera(CameraUpdate.newLatLng(destLocation!));
      }
    } else {
      showSnackBar(context, 'Please Enter Valid coordinates');
    }
  }

  Set<Marker> _createMarkers() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Center Screen'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startMap,
                child: const Text('Start'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _stopMap,
                child: const Text('Stop'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Latitude',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Longitude',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _setDestination,
                  child: const Text('Set Destination'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _isMapStarted
                  ? GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(28.6139,
                            77.2090), // Default coordinates before getting the live location
                        zoom: 10,
                      ),
                      markers: _createMarkers(),
                    )
                  : const Center(
                      child: Text('Map is stopped.'),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
