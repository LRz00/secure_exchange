import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../theme/colors.dart';

class DetalhesObjetoPage extends StatelessWidget {
  final ParseObject objeto;

  const DetalhesObjetoPage({Key? key, required this.objeto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imagem = objeto.get<ParseFile>('imagem');
    final titulo = objeto.get<String>('titulo') ?? '';
    final descricao = objeto.get<String>('descricao') ?? '';
    final estado = objeto.get<String>('estadoConservacao') ?? '';
    final preferencia = objeto.get<String>('preferencia') ?? '';
    final tipoNegociacao = objeto.get<String>('tipoNegociacao') ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Objeto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            imagem != null
                ? Image.network(imagem.url!, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 100),
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
                // futura lógica de proposta de troca
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
              onPressed: () {
                // futura lógica para chat ou contato
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
