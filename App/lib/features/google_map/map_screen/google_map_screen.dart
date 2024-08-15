// map_screen.dart

import 'package:cap_1/common/widgets/snackbar.dart';
import 'package:cap_1/components/buttons.dart';
import 'package:cap_1/features/google_map/services/map_screen_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapPageState();
}

class _MapPageState extends State<MapScreen> {
  final MapServices _mapServices = MapServices();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _mapServices.accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapServices.controller = controller;
  }

  void _startMap() async {
    try {
      await _mapServices.startMap();
      setState(() {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _stopMap() {
    _mapServices.stopMap();
    setState(() {});
  }

  void _setDestination() {
    final double? latitude = double.tryParse(_latitudeController.text);
    final double? longitude = double.tryParse(_longitudeController.text);
    try {
      _mapServices.setDestination(latitude, longitude);
      setState(() {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
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
              child: _mapServices.startLocation != null
                  ? GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(28.6139, 77.2090),
                        zoom: 10,
                      ),
                      markers: _mapServices.createMarkers(),
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
                  child: _mapServices.accelerometerValues.isNotEmpty
                      ? Text(
                          'X: ${_mapServices.accelerometerValues[0].x.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                          ),
                        )
                      : const Text('0.0'),
                ),
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
                  child: _mapServices.accelerometerValues.isNotEmpty
                      ? Text(
                          'Y: ${_mapServices.accelerometerValues[0].y.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                          ),
                        )
                      : const Text('0.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _mapServices.address.isEmpty
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
                            _mapServices.address,
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
                            onPressed: _startMap,
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

