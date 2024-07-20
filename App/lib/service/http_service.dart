import 'dart:convert';
import 'package:cap_1/common/widgets/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class HttpService {
  static final _client = http.Client();

  static final _loginUrl = Uri.parse(
      'http://10.0.2.2:5001/login'); // Use 10.0.2.2 for Android emulator
  static final _registerUrl = Uri.parse(
      'http://10.0.2.2:5001/register'); // Use 10.0.2.2 for Android emulator

  static Future<void> login(
      String email, String pass, BuildContext context) async {
    try {
      http.Response response = await _client.post(
        _loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': pass}),
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        if (json is Map<String, dynamic> && json['status'] != null) {
          if (json['status'] == "success") {
            await EasyLoading.showSuccess(json['status']);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => BottomBar()));
          } else {
            EasyLoading.showError(json['status']);
          }
        } else {
          EasyLoading.showError("Invalid response from server");
        }
      } else {
        EasyLoading.showError("Error Code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: ${e.toString()}");
    }
  }

  static Future<void> register(
      String username, String email, String pass, BuildContext context) async {
    try {
      http.Response response = await _client.post(
        _registerUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': pass}),
      );

      if (response.statusCode == 201) {
        var json = jsonDecode(response.body);

        if (json is Map<String, dynamic> && json['message'] != null) {
          await EasyLoading.showSuccess(json['message']);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BottomBar()));
        } else {
          EasyLoading.showError("Invalid response from server");
        }
      } else if (response.statusCode == 400) {
        var json = jsonDecode(response.body);
        EasyLoading.showError(json['message']);
      } else {
        EasyLoading.showError("Error Code : ${response.statusCode.toString()}");
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: ${e.toString()}");
    }
  }
}
