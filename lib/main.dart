import 'package:flutter/material.dart';
import 'package:secure_exchange/theme/colors.dart';
import 'pages/save-object.dart'; // certifique-se de que o caminho está correto

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Objetos',
      theme: ThemeData(primarySwatch: customSwatch),
      home: SalvarObjetoPage(), // <-- Tela inicial
      debugShowCheckedModeBanner: false,
    );
  }
}
