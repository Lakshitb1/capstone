import 'dart:convert';
import 'dart:io';  // Add this for socket exceptions
import 'package:cap_1/common/service/error_handling.dart';
import 'package:cap_1/common/widgets/dashboard_screen.dart';
import 'package:cap_1/common/widgets/snackbar.dart';
import 'package:cap_1/models/user.dart';
import 'package:cap_1/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AuthService {
  void register({
    required BuildContext context,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      User user = User(
        id: '',
        username: username,
        email: email,
        password: password,
        token: '',
        address: '',
      );
      http.Response res = await http.post(
        Uri.parse('https://capstone-1-25k0.onrender.com/register'),  // Updated URL
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            jsonDecode(res.body)['message'],  // Extract the message properly
          );
        },
      );
    } on SocketException catch (e) {
      showSnackBar(context, 'No Internet connection: $e');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void loginUser({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    http.Response res = await http.post(
      Uri.parse('https://capstone-1-25k0.onrender.com/login'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // HTTP error handling
    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () async {
        final responseBody = jsonDecode(res.body);

        // Validate token existence
        if (responseBody['token'] == null) {
          showSnackBar(context, 'Token not found in response');
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        Provider.of<UserProvider>(context, listen: false).setUser(res.body);
        await prefs.setString('x-auth-token', responseBody['token']);

        if (!context.mounted) return;

        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomBar(),
          ),
        );
      },
    );
  } on SocketException catch (e) {
    showSnackBar(context, 'No Internet connection: $e');
  } catch (e) {
    showSnackBar(context, 'Unexpected error: $e');
  }
}


  void getUserData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      if (token == null) {
        prefs.setString('x-auth-token', '');
        token = '';
      }
      
      var tokenRes = await http.post(
        Uri.parse('https://capstone-1-25k0.onrender.com/tokenIsValid'),  // Updated URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('https://capstone-1-25k0.onrender.com/'),  // Updated URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      } else {
        showSnackBar(context, 'Invalid token');
      }
    } on SocketException catch (e) {
      showSnackBar(context, 'No Internet connection: $e');
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
