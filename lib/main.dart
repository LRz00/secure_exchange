import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:secure_exchange/theme/colors.dart';
import 'pages/save-object.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure EXchange',
      theme: ThemeData(primarySwatch: customSwatch),
      home: SalvarObjetoPage(), //substituir por tela principal ou a que estiver desenvolvendo
      debugShowCheckedModeBanner: false,
    );
  }
}
