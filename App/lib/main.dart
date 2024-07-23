//import 'package:cap_1/common/widgets/dashboard_screen.dart';
/*import 'package:cap_1/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pages/account_pages/login_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      builder: EasyLoading.init(),
    );
  }
}
*/
import 'package:cap_1/common/widgets/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cap_1/providers/user_provider.dart';
import 'features/authentication/account_pages/login_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else {
          if (snapshot.data == true) {
            // If the user is logged in, show the BottomBar screen
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const BottomBar(),
              builder: EasyLoading.init(),
            );
          } else {
            // If the user is not logged in, show the LoginPage
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: LoginPage(),
              builder: EasyLoading.init(),
            );
          }
        }
      },
    );
  }
}
