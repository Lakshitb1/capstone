import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  // Fetch user history data
  Future<List<Map<String, dynamic>>> fetchHistoryData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');
    print('Token Retrieved: $token');

    if (token == null || token.isEmpty) {
      throw Exception('User is not logged in.');
    }

    // Decode token or directly retrieve the username/user_id.
    String username = getUsernameFromToken(token);
    print('Extracted Username: $username');

    final String apiUrl =
        'http://192.168.216.207:5002/get_user_readings?username=';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print('API Response: $jsonData');
      if (jsonData['status'] == 'success') {
        return List<Map<String, dynamic>>.from(jsonData['readings']);
      } else {
        throw Exception(jsonData['message'] ?? 'Unknown error occurred.');
      }
    } else {
      throw Exception(
          'Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error fetching history data: $e');
  }
}


  // Extract username from token
  String getUsernameFromToken(String token) {
    try {
      // Assuming the token contains a 'username' field.
      Map<String, dynamic> payload = _parseJwt(token);
      return payload['username'] ?? '';
    } catch (e) {
      throw Exception('Invalid token format: $e');
    }
  }

  // Decode JWT (adjust the method according to your actual token format)
  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT format.');
    }
    final payload = _decodeBase64(parts[1]);
    return json.decode(payload);
  }

  // Helper method to decode Base64
  String _decodeBase64(String str) {
    String normalized = str.replaceAll('-', '+').replaceAll('_', '/');
    return utf8.decode(base64Url.decode(normalized));
  }
}
