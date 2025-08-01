import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:secure_exchange/pages/home.dart';
import 'package:secure_exchange/theme/colors.dart';
import 'pages/auth/login.dart';
import 'pages/auth/sign-up.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env"); // <- carrega o .env

  await Parse().initialize(
    dotenv.env['PARSE_APPLICATION_ID']!,
    dotenv.env['PARSE_SERVER_URL']!,
    clientKey: dotenv.env['PARSE_CLIENT_KEY'],
    autoSendSessionId: true,
    debug: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure EXchange',
      theme: ThemeData(primarySwatch: customSwatch),
      home: WelcomePage(),
      routes: {
        '/login': (_) => TelaLoginPage(),
        '/cadastro': (_) => TelaCadastroPage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
