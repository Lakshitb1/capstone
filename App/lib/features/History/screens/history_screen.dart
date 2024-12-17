import 'package:flutter/material.dart';
import 'package:cap_1/features/History/services/history_services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService(); // Corrected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // Fetch data here
        future: _historyService.fetchHistoryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No history available."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                return ListTile(
                  title: Text(data['label'] ?? 'No Label'),
                  subtitle: Text(
                    "Timestamp: ${data['timestamp'] ?? 'Unknown'}\n"
                    "X: ${data['x'] ?? 0}, Y: ${data['y'] ?? 0}, Z: ${data['z'] ?? 0}",
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
