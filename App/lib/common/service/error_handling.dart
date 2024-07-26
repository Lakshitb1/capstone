import 'dart:convert';
import 'dart:ui';

import 'package:cap_1/common/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void httpErrorHandle({required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,}){
    switch (response.statusCode) {
    case 201:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 500:
      showSnackBar(context, jsonDecode(response.body)['error']);
      break;
    default:
      showSnackBar(context, response.body);
  }
  }