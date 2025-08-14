import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io' as io;

import '../theme/colors.dart';

import 'item-list.dart';
import 'chat-list-page.dart';
import 'profile-page.dart';

class SalvarObjetoPage extends StatefulWidget {
  @override
  _SalvarObjetoPageState createState() => _SalvarObjetoPageState();
}

class _SalvarObjetoPageState extends State<SalvarObjetoPage> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _preferenciaController = TextEditingController();

  String? _estadoConservacao;
  String? _tipoNegociacao;
  
  // NOVO: Variável de estado para o rodapé (índice 1 = Adicionar)
  int _paginaAtual = 1;

  Uint8List? _webImage;
  io.File? _mobileImage;

  // NOVO: Lógica de navegação para o rodapé
  void _onItemTapped(int index) async {
    if (_paginaAtual == index) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ListaObjetosPage()),
        (Route<dynamic> route) => false,
      );
    } else if (index == 1) {
      // Já estamos na página de Adicionar
    } else if (index == 2) {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: currentUser),
          ),
        );
      }
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatsListPage()),
      );
    }
  }

  Future<void> _selecionarImagem() async {
    // ... seu código para selecionar imagem continua o mesmo ...
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _mobileImage = io.File(pickedFile.path);
        });
      }
    }
  }

  void _salvarObjeto() async {
    // ... seu código para salvar o objeto continua o mesmo ...
    final currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário não está logado')),
      );
      return;
    }

    ParseFileBase? parseFile;

    if (kIsWeb && _webImage != null) {
      parseFile = ParseWebFile(_webImage!, name: "imagem.jpg");
    } else if (!kIsWeb && _mobileImage != null) {
      parseFile = ParseFile(_mobileImage!);
    }
    
    if (parseFile != null) {
      await parseFile.save();
    }

    final objeto = ParseObject('Objeto')
      ..set('titulo', _tituloController.text)
      ..set('descricao', _descricaoController.text)
      ..set('estadoConservacao', _estadoConservacao)
      ..set('preferencia', _preferenciaController.text)
      ..set('tipoNegociacao', _tipoNegociacao)
      ..set('dono', currentUser);

    if (parseFile != null) {
      objeto.set('imagem', parseFile);
    }

    final response = await objeto.save();

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objeto salvo com sucesso!')),
      );
      Navigator.pop(context, true); // Retorna true para indicar sucesso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${response.error?.message}')),
      );
    }
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ... Todos os seus TextFields e Dropdowns continuam os mesmos ...
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              value: _estadoConservacao,
              items: ['Novo', 'Semi-novo', 'Usado', 'Com defeito'].map((estado) {
                return DropdownMenuItem(value: estado, child: Text(estado));
              }).toList(),
              onChanged: (valor) => setState(() => _estadoConservacao = valor),
              decoration: InputDecoration(labelText: 'Estado de Conservação'),
            ),
            TextField(
              controller: _preferenciaController,
              decoration: InputDecoration(labelText: 'Preferência de Troca'),
            ),
            DropdownButtonFormField<String>(
              value: _tipoNegociacao,
              items: ['Troca', 'Venda', 'Doação'].map((tipo) {
                return DropdownMenuItem(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (valor) => setState(() => _tipoNegociacao = valor),
              decoration: InputDecoration(labelText: 'Tipo de Negociação'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selecionarImagem,
              icon: Icon(Icons.image),
              label: Text('Selecionar Imagem'),
            ),
            if (_mobileImage != null || _webImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: kIsWeb
                  ? Image.memory(_webImage!, height: 150)
                  : Image.file(_mobileImage!, height: 150),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _salvarObjeto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: contrastColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Salvar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: contrastColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // NOVO: Rodapé adicionado ao Scaffold
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}