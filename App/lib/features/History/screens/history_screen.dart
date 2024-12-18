import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cap_1/features/History/services/history_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  bool _showAll = false;

  final String streamlitURL =
      "https://bumpanalytics-temcuvxlzp23whlmomt4fc.streamlit.app/";

  Future<void> showAnalysis() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in. Auth token is missing.');
    }

    final String backendAPI = 'http://capstone-1-25k0.onrender.com/fetch_all_readings';
    print('Backend API URL: $backendAPI');

    // Make a GET request with the token in headers
    final response = await http.get(
      Uri.parse(backendAPI),
      headers: {
        'x-auth-token': token, // Pass the token in headers
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('API Response: ${response.body}');

      // Build final Streamlit URL
      final Uri url = Uri.parse("$streamlitURL?api=${Uri.encodeComponent(backendAPI)}");
      print('Launching URL: $url');

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch URL: $url');
      }
    } else {
      throw Exception(
          'Failed to fetch all readings. Status code: ${response.statusCode}');
    }
  } catch (err) {
    print('Error: $err');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $err')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyService.fetchHistoryData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No history available.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            } else {
              final data = snapshot.data!;
              final visibleData = _showAll ? data : data.take(4).toList();

              return Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visibleData.length,
                      itemBuilder: (context, index) {
                        final item = visibleData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          child: Card(
                            elevation: 4,
                            shadowColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blueAccent,
                                child: const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                item['label'] ?? 'No Label',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Timestamp: ${item['timestamp'] ?? 'Unknown'}\n"
                                  "X: ${item['x'] ?? 0}, Y: ${item['y'] ?? 0}, Z: ${item['z'] ?? 0}",
                                  style: TextStyle(
                                      color: Colors.grey.shade700, height: 1.4),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // "See More" / "See Less" Button
                  if (data.length > 4)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAll = !_showAll;
                        });
                      },
                      child: Text(
                        _showAll ? 'See Less' : 'See More',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                  // "Detailed Analysis" Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => showAnalysis(),
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      label: const Text(
                        'Detailed Analysis',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
