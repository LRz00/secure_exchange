import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:secure_exchange/pages/item-list.dart';
import '../../theme/colors.dart';

class TelaLoginPage extends StatefulWidget {
  @override
  _TelaLoginPageState createState() => _TelaLoginPageState();
}

class _TelaLoginPageState extends State<TelaLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  String? _mensagemErro;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    final usuario = ParseUser(
      _emailController.text.trim(),
      _senhaController.text.trim(),
      null,
    );

    final response = await usuario.login();

    setState(() {
      _carregando = false;
    });

    if (response.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ListaObjetosPage()),
      );
    } else {
      setState(() {
        _mensagemErro = response.error?.message ?? 'Erro desconhecido.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: primaryColor,
        foregroundColor: contrastColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              SizedBox(height: 24),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Informe seu e-mail' : null,
              ),

              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),

              SizedBox(height: 16),

              if (_mensagemErro != null)
                Text(
                  _mensagemErro!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),

              SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _fazerLogin,
                  child: _carregando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Entrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: contrastColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/cadastro');
                },
                child: Text('Ainda não tem conta? Cadastre-se'),
                style: TextButton.styleFrom(
                  foregroundColor: secondaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
