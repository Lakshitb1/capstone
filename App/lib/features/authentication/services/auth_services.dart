import 'dart:convert';
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
        Uri.parse('http://10.0.2.2:5001/register'),
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
            jsonDecode(res.body)['message'],
          );
        },
      );
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
        Uri.parse('http://10.0.2.2:5001/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences pref = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await pref.setString('x-auth-token', jsonDecode(res.body)['token']);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomBar(),
            ),
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
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
        Uri.parse('http://10.0.2.2:5001/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('http://10.0.2.2:5001/getUserData'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}

/*import 'dart:convert';
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
*/