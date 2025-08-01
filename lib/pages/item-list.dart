import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../theme/colors.dart';
import 'item-detail.dart';
import 'save-object.dart';

class ListaObjetosPage extends StatefulWidget {
  @override
  _ListaObjetosPageState createState() => _ListaObjetosPageState();
}

class _ListaObjetosPageState extends State<ListaObjetosPage> {
  List<ParseObject> objetos = [];
  String filtroTitulo = '';
  int _paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _buscarObjetos();
  }

  Future<void> _buscarObjetos() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Objeto'));
    if (filtroTitulo.isNotEmpty) {
      query.whereContains('titulo', filtroTitulo);
    }

    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        objetos = response.results as List<ParseObject>;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      filtroTitulo = value;
    });
    _buscarObjetos();
  }

  Widget _buildItem(ParseObject objeto) {
    final titulo = objeto.get<String>('titulo') ?? '';
    final descricao = objeto.get<String>('descricao') ?? '';
    final imagemParseFile = objeto.get<ParseFileBase>('imagem');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalhesObjetoPage(objeto: objeto),
          ),
        ).then((_) {
          _buscarObjetos();
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: imagemParseFile != null
              ? Image.network(
                  imagemParseFile.url!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: Icon(Icons.image_not_supported),
                ),
          title: Text(titulo),
          subtitle:
              Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SalvarObjetoPage()),
      ).then((result) {
        if (result == true) {
          _buscarObjetos();
        }
      });
    } else if (index == 2) {
      // Navegar para a tela de perfil (futura)
    } else {
      // Tela atual
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objetos'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Buscar por título',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: objetos.isEmpty
                  ? Center(child: Text('Nenhum objeto encontrado.'))
                  : ListView.builder(
                      itemCount: objetos.length,
                      itemBuilder: (context, index) =>
                          _buildItem(objetos[index]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
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
        ],
      ),
    );
  }
}
