import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../theme/colors.dart';

class TelaCadastroPage extends StatefulWidget {
  @override
  _TelaCadastroPageState createState() => _TelaCadastroPageState();
}

class _TelaCadastroPageState extends State<TelaCadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _ruaController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();

  bool _carregando = false;
  String? _mensagemErro;

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    final usuario = ParseUser(
      _emailController.text.trim(),
      _senhaController.text.trim(),
      _emailController.text.trim(),
    );

    usuario.set('nome', _nomeController.text.trim());
    usuario.set('rua', _ruaController.text.trim());
    usuario.set('cidade', _cidadeController.text.trim());
    usuario.set('estado', _estadoController.text.trim());

    final response = await usuario.signUp();

    setState(() {
      _carregando = false;
    });

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta criada com sucesso!')),
      );
      // Navegar para a tela principal ou de login
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
        title: Text('Criar Conta'),
        backgroundColor: primaryColor,
        foregroundColor: contrastColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo SVG
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),
              SizedBox(height: 24),

              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value!.isEmpty ? 'Informe seu nome' : null,
              ),

              // E-mail
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Informe seu e-mail' : null,
              ),

              // Senha
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),

              // Endereço
              TextFormField(
                controller: _ruaController,
                decoration: InputDecoration(labelText: 'Rua'),
              ),
              TextFormField(
                controller: _cidadeController,
                decoration: InputDecoration(labelText: 'Cidade'),
              ),
              TextFormField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
              ),

              SizedBox(height: 16),

              // Mensagem de erro
              if (_mensagemErro != null)
                Text(_mensagemErro!,
                    style: TextStyle(color: Colors.red, fontSize: 14)),

              SizedBox(height: 16),

              // Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _criarConta,
                  child: _carregando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Criar Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: contrastColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Link para login
              TextButton(
                onPressed: () {
                   Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Já tem conta? Faça login'),
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
