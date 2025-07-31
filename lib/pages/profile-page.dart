import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// ALTERAÇÃO 1: Convertido para StatefulWidget
class ProfilePage extends StatefulWidget {
  // A página agora recebe o usuário cujo perfil será exibido
  final ParseUser user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ParseObject> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserItems();
  }

  // ALTERAÇÃO 2: Função para carregar os itens do usuário do banco de dados
  Future<void> _loadUserItems() async {
    // Substitua 'Objeto' pelo nome da sua classe de itens no Parse
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Objeto'))
      ..whereEqualTo('dono', widget.user); // Filtra os itens pelo dono

    final response = await queryBuilder.query();

    if (response.success && response.results != null) {
      setState(() {
        _items = response.results as List<ParseObject>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Opcional: mostrar um erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar itens: ${response.error?.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ALTERAÇÃO 3: Dados do usuário agora são dinâmicos
    final nome = widget.user.get<String>('nome') ?? 'Usuário';
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Avatar dinâmico
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color.fromRGBO(230, 229, 235, 1),
              child: Text(
                inicial,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // Nome do usuário dinâmico
            Text(
              nome,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // ALTERAÇÃO 4: Lista de itens dinâmica
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(
                          child: Text(
                          'Este usuário não possui itens cadastrados.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _buildListItem(item); // Passa o objeto para o widget
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // ALTERAÇÃO 5: O widget agora recebe um ParseObject
  Widget _buildListItem(ParseObject item) {
    final titulo = item.get<String>('titulo') ?? 'Item sem título';
    final descricao = item.get<String>('descricao') ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descricao,
            style: const TextStyle(
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}