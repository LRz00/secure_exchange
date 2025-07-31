import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io' as io;

import '../theme/colors.dart';

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
  File? _imagemSelecionada;

  final List<String> estadosConservacao = [
    'Novo',
    'Semi-novo',
    'Usado',
    'Com defeito',
  ];

  final List<String> tiposNegociacao = [
    'Troca',
    'Venda',
    'Doação',
  ];

  Uint8List? _webImage;
  io.File? _mobileImage;

  Future<void> _selecionarImagem() async {
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
      await parseFile.save();
    } else if (_mobileImage != null) {
      parseFile = ParseFile(_mobileImage!);
      await parseFile.save();
    }

    final objeto = ParseObject('Objeto')
      ..set('titulo', _tituloController.text)
      ..set('descricao', _descricaoController.text)
      ..set('estadoConservacao', _estadoConservacao)
      ..set('preferencia', _preferenciaController.text)
      ..set('tipoNegociacao', _tipoNegociacao)
      ..set('dono', currentUser); // <- Aqui associamos o dono

    if (parseFile != null) {
      objeto.set('imagem', parseFile);
    }

    final response = await objeto.save();

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objeto salvo com sucesso!')),
      );
      Navigator.pop(context, true);
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
              items: estadosConservacao.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado),
                );
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
              items: tiposNegociacao.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo),
                );
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
            if (_imagemSelecionada != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(
                  _imagemSelecionada!,
                  height: 150,
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
    );
  }
}
