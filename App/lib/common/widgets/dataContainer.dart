import 'package:flutter/material.dart';

// Define the widget
Widget buildDataContainer(String label, double value) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: Colors.blueAccent),
    ),
    child: Text(
      '$label: ${value.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 14, // Adjusted font size for better visibility
      ),
    ),
  );
}
