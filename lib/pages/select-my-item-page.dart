
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SelectMyItemPage extends StatefulWidget {
  const SelectMyItemPage({Key? key}) : super(key: key);

  @override
  _SelectMyItemPageState createState() => _SelectMyItemPageState();
}

class _SelectMyItemPageState extends State<SelectMyItemPage> {
  Future<List<ParseObject>> _loadMyItems() async {
    final currentUser = await ParseUser.currentUser();
    if (currentUser == null) {
      return []; 
    }

    final query = QueryBuilder<ParseObject>(ParseObject('Objeto'))
      ..whereEqualTo('dono', currentUser);


    final response = await query.query();

    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione um Item para Ofertar'),
      ),
      body: FutureBuilder<List<ParseObject>>(
        future: _loadMyItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você não possui itens cadastrados.'));
          }

          final myItems = snapshot.data!;

          return ListView.builder(
            itemCount: myItems.length,
            itemBuilder: (context, index) {
              final item = myItems[index];
              final titulo = item.get<String>('titulo') ?? 'Item sem título';
              final imagem = item.get<ParseFileBase>('imagem');

              return ListTile(
                leading: (imagem != null && imagem.url != null)
                    ? Image.network(imagem.url!, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 50),
                title: Text(titulo),
                onTap: () {
                  Navigator.of(context).pop(item);
                },
              );
            },
          );
        },
      ),
    );
  }
}