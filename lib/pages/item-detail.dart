import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'trading-page.dart';

import 'chat-page.dart';
import '../theme/colors.dart';

class DetalhesObjetoPage extends StatefulWidget {
  final ParseObject objeto;

  const DetalhesObjetoPage({Key? key, required this.objeto}) : super(key: key);

  @override
  State<DetalhesObjetoPage> createState() => _DetalhesObjetoPageState();
}

class _DetalhesObjetoPageState extends State<DetalhesObjetoPage> {
  ParseUser? dono;
  String? nomeDono;

  @override
  void initState() {
    super.initState();
    _carregarDono();
  }

  Future<void> _carregarDono() async {
    final donoPointer = widget.objeto.get<ParseUser>('dono');

    if (donoPointer != null) {
      final ParseUser? donoCompleto = (await donoPointer.fetch()) as ParseUser?;

      setState(() {
        dono = donoCompleto;
        nomeDono = donoCompleto?.get<String>('nome') ?? 'Usuário';
      });
    }
  }

Future<void> definirSchemaDoChat() async {
  print("Tentando definir o esquema da classe 'Chat'...");

  final dummyUser1 = ParseObject('_User')..objectId = 'dummy_user_id_1';
  final dummyUser2 = ParseObject('_User')..objectId = 'dummy_user_id_2';
  

  final chatSchemaSetter = ParseObject('Chat')
    ..set('participants', [dummyUser1, dummyUser2]);

  try {
    final response = await chatSchemaSetter.save();

    if (response.success) {
      print("✅ Esquema definido com sucesso! O objeto foi salvo.");
      await response.result.delete();
      print("✅ Objeto de teste deletado.");
    } else {
      print("ℹ️ Ocorreu um erro ao salvar (o que pode ser normal se a coluna já existe), mas o esquema deve ter sido atualizado. Verifique o painel.");
      print("Erro: ${response.error?.message}");
    }
  } catch(e) {
    print("Ocorreu uma exceção: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final imagem = widget.objeto.get<ParseFileBase>('imagem');
    final titulo = widget.objeto.get<String>('titulo') ?? '';
    final descricao = widget.objeto.get<String>('descricao') ?? '';
    final estado = widget.objeto.get<String>('estadoConservacao') ?? '';
    final preferencia = widget.objeto.get<String>('preferencia') ?? '';
    final tipoNegociacao = widget.objeto.get<String>('tipoNegociacao') ?? '';
    final dataCadastro = widget.objeto.createdAt;
    
    const Color primaryColor = Color.fromRGBO(40, 0, 109, 1);
    const Color contrastColor = Colors.white;

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Objeto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (nomeDono != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor,
                    child: Text(
                      nomeDono![0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeDono!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (dataCadastro != null)
                        Text(
                          'Cadastrado em ${dataCadastro.day.toString().padLeft(2, '0')}/${dataCadastro.month.toString().padLeft(2, '0')}/${dataCadastro.year}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ],
              )
            else
              const Center(child: CircularProgressIndicator()),
            
            const SizedBox(height: 16),

            if (imagem != null && imagem.url != null)
              Image.network(imagem.url!, height: 200, fit: BoxFit.cover)
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
              ),

            const SizedBox(height: 16),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Descrição: $descricao'),
            const SizedBox(height: 8),
            Text('Estado de conservação: $estado'),
            const SizedBox(height: 8),
            Text('Preferência de troca: $preferencia'),
            const SizedBox(height: 8),
            Text('Tipo de negociação: $tipoNegociacao'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TradingPage( 
                      itemDesejado: widget.objeto,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: contrastColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Propor Troca'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: dono == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(destinatario: dono!),
                        ),
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: contrastColor,
                side: BorderSide(color: primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Falar com o Dono'),
            ),
          ],
        ),
      ),
    );
  }
}