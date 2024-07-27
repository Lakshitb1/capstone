
import 'package:cap_1/common/widgets/dashboard_screen.dart';
import 'package:cap_1/features/authentication/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cap_1/providers/user_provider.dart';
import 'features/authentication/account_pages/login_page.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bump Buster',
      home: Provider.of<UserProvider>(context).user.token.isNotEmpty
          ?const BottomBar()
          : LoginPage(),
    );
  }
}
