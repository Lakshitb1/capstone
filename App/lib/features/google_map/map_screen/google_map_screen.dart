import 'package:cap_1/common/widgets/snackbar.dart';
import 'package:cap_1/components/buttons.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapPageState();
}

class _MapPageState extends State<MapScreen> {
  late GoogleMapController _controller;
  bool _isMapStarted = false;
  String address = "";
  late Position currentposition;
  LatLng? startLocation;
  LatLng? destLocation;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _startMap() async {
    setState(() {
      _isMapStarted = true;

      startLocation = null;
      destLocation = null;
      address = "";
    });
    Future<void> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackBar(context, 'Please enable your location service');
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackBar(context, 'Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackBar(context,
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];

        setState(() {
          startLocation = LatLng(position.latitude, position.longitude);
          address =
              "${place.name}, ${place.street}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        });

        _controller.animateCamera(CameraUpdate.newLatLng(startLocation!));
      } catch (e) {
        print(e);
      }
    }

    await _determinePosition();
  }

  void _stopMap() {
    setState(() {
      _isMapStarted = false;
      startLocation = null;
      destLocation = null;
      address = "";
    });

    if (_controller != null) {
      _controller.animateCamera(
        CameraUpdate.newLatLng(const LatLng(28.6139, 77.2090)),
      );
    }
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Map Center Screen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Map Container

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
                        target: LatLng(28.6139, 77.2090),
                        zoom: 10,
                      ),
                      markers: _createMarkers(),
                    )
                  : const Center(
                      child: Text(
                        'Map is stopped.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    '0.0 m/s',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '0.0 m/s',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              address.isEmpty
                  ? CustomButton(text: 'Start Driving', onPressed: _startMap)
                  : Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                _startMap();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              CustomButton(text: 'Stop Execution', onPressed: _stopMap),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
