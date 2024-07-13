import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cap_1/pages/dashboard_screen.dart';

class HttpService {
  static final _client = http.Client();

  static final _loginUrl = Uri.parse(
      'http://10.0.2.2:5000/login'); // Use 10.0.2.2 for Android emulator

  static final _registerUrl = Uri.parse(
      'http://10.0.2.2:5000/register'); // Use 10.0.2.2 for Android emulator

  static login(username, pass, context) async {
    http.Response response = await _client.post(_loginUrl, body: {
      'uname': username,
      'passw': pass,
    });

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      var json = jsonDecode(response.body);

      if (json['status'] == 'Login Successfully') {
        await EasyLoading.showSuccess(json['status']);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        EasyLoading.showError(json['status']);
      }
    } else {
      await EasyLoading.showError(
          "Error Code : ${response.statusCode.toString()}");
    }
  }

  static register(username, email, pass, context) async {
    http.Response response = await _client.post(_registerUrl, body: {
      'uname': username,
      'mail': email,
      'passw': pass,
    });

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'username already exist') {
        await EasyLoading.showError(json['status']);
      } else {
        await EasyLoading.showSuccess(json['status']);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashboardScreen()));
      }
    } else {
      await EasyLoading.showError(
          "Error Code : ${response.statusCode.toString()}");
    }
  }
}
