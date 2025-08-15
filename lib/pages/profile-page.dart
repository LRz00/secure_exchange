import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'item-list.dart'; // Supondo que o nome do arquivo seja este
import 'save-object.dart';
import 'chat-list-page.dart';
import '../theme/colors.dart'; // Mantenha se você tiver este arquivo de cores

// Enum para controlar o estado dos botões "Pendente/Finalizada"
enum StatusFiltro { pendente, finalizada }

class ProfilePage extends StatefulWidget {
  final ParseUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ParseObject> _items = [];
  bool _isLoading = true;

  // Variáveis de estado para os filtros das novas abas
  StatusFiltro _negociacaoStatus = StatusFiltro.pendente;
  StatusFiltro _propostaStatus = StatusFiltro.pendente;

  // NOVO: Variável de estado para controlar o item selecionado na barra inferior
  // O valor é 2, pois "Perfil" é o terceiro item (índice 2)
  int _paginaAtual = 2;

  @override
  void initState() {
    super.initState();
    _loadUserItems();
    _loadNegociacoes();
    _loadPropostas();
  }

  void _onItemTapped(int index) async {
    // Se o usuário clicar no ícone que já está selecionado, não faz nada
    if (_paginaAtual == index) return;

    // Lógica para o botão "Início" (índice 0)
    if (index == 0) {
      // Navega para a tela inicial, limpando as telas anteriores
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ListaObjetosPage()),
        (Route<dynamic> route) => false,
      );
    }
    // Lógica para o botão "Adicionar" (índice 1)
    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SalvarObjetoPage()),
      ).then((result) {
        // Se um item foi salvo, recarrega os itens do perfil
        if (result == true) {
          _loadUserItems();
        }
      });
    }
    // O índice 2 é a própria página de Perfil, então não fazemos nada.
    else if (index == 2) {
      // Já estamos na página de perfil
    }
    // Lógica para o botão "Chats" (índice 3)
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatsListPage()),
      );
    }
  }

  Future<void> _loadUserItems() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Objeto'))
      ..whereEqualTo('dono', widget.user);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar itens: ${response.error?.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ParseObject> _negociacoes = [];
  List<ParseObject> _propostas = [];

  Future<void> _loadNegociacoes() async {
    final query = QueryBuilder<ParseObject>(ParseObject('PropostaTroca'))
      ..whereEqualTo('destinatario', widget.user)
      ..whereEqualTo('status', _negociacaoStatus.name)
      ..includeObject(
          ['itemDesejado', 'remetente']); // Carrega os objetos relacionados

    final res = await query.query();
    if (res.success && res.results != null) {
      setState(() => _negociacoes = res.results!.cast<ParseObject>());
    }
     setState(() {});
  }

  Future<void> _loadPropostas() async {
    final query = QueryBuilder<ParseObject>(ParseObject('PropostaTroca'))
      ..whereEqualTo('remetente', widget.user)
      ..whereEqualTo('status', _propostaStatus.name)
      ..includeObject(
          ['itemDesejado', 'destinatario']); // Carrega os objetos relacionados

    final res = await query.query();
    if (res.success && res.results != null) {
      setState(() => _propostas = res.results!.cast<ParseObject>());
    }
     setState(() {});
  }

  int _countNegociacoesPendentes() {
    return _negociacoes
        .where((proposta) => proposta.get<String>('status') == 'pendente')
        .length;
  }

  int _countPropostasPendentes() {
    return _propostas
        .where((proposta) => proposta.get<String>('status') == 'pendente')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final nome = widget.user.get<String>('nome') ?? 'Usuário';
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

    return DefaultTabController(
      length: 3, // O número de abas
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 200,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color.fromRGBO(230, 229, 235, 1),
                  child: Text(inicial,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
                const SizedBox(height: 12),
                Text(nome,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color.fromRGBO(40, 0, 109, 1),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('MEUS ITENS'),                    
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('NEGOCIAÇÕES'),
                    if (_countNegociacoesPendentes() > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            _countNegociacoesPendentes().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('PROPOSTAS'),
                    if (_countPropostasPendentes() > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            _countPropostasPendentes().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMeusItensTab(),
            _buildNegociacoesTab(),
            _buildPropostasTab(),
          ],
        ),

        // ALTERADO: A barra de navegação antiga foi substituída por esta
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _paginaAtual,
          onTap: _onItemTapped,
          // Use a cor do seu tema ou uma cor padrão
          selectedItemColor: const Color.fromRGBO(40, 0, 109, 1),
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
      ),
    );
  }

  // O restante do seu código (_buildMeusItensTab, _buildNegociacoesTab, etc.)
  // permanece exatamente o mesmo. Cole ele aqui.
  // ...
  Widget _buildMeusItensTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(
          child: Text('Você não possui itens cadastrados.',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildListItem(item);
      },
    );
  }

  Widget _buildNegociacoesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<StatusFiltro>(
            segments: const [
              ButtonSegment(
                  value: StatusFiltro.pendente, label: Text('Pendentes')),
              ButtonSegment(
                  value: StatusFiltro.finalizada, label: Text('Finalizadas')),
            ],
            selected: {_negociacaoStatus},
            onSelectionChanged: (newSelection) {
              setState(() {
                _negociacaoStatus = newSelection.first;
              });
              _loadNegociacoes();
            },
          ),
        ),
        Expanded(
          child: _negociacoes.isEmpty
              ? const Center(child: Text('Nenhuma negociação encontrada.'))
              : ListView.builder(
                  itemCount: _negociacoes.length,
                  itemBuilder: (context, index) {
                    final proposta = _negociacoes[index];
                    final itemDesejado =
                        proposta.get<ParseObject>('itemDesejado');
                    final itensOfertados =
                        proposta.get<List<dynamic>>('itensOfertados') ?? [];
                    final remetente = proposta.get<ParseUser>('remetente');

                    return ListTile(
                      title: Text(
                          'Proposta de ${remetente?.get<String>('nome') ?? 'Usuário'}'),
                      subtitle: Text(
                        'Deseja: ${itemDesejado?.get<String>('titulo') ?? 'Item desconhecido'}\n'
                        'Ofertas: ${itensOfertados.length} item(ns)',
                      ),
                      trailing: proposta.get<num>('valorEmDinheiro') != null
                          ? Text('R\$ ${proposta.get<num>('valorEmDinheiro')}')
                          : null,
                      onTap: () {
                        // Aqui você pode adicionar navegação para detalhes da proposta
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPropostasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<StatusFiltro>(
            segments: const [
              ButtonSegment(
                  value: StatusFiltro.pendente, label: Text('Pendentes')),
              ButtonSegment(
                  value: StatusFiltro.finalizada, label: Text('Finalizadas')),
            ],
            selected: {_propostaStatus},
            onSelectionChanged: (newSelection) {
              setState(() {
                _propostaStatus = newSelection.first;
              });
              _loadPropostas();
            },
          ),
        ),
        Expanded(
          child: _propostas.isEmpty
              ? const Center(child: Text('Nenhuma proposta enviada.'))
              : ListView.builder(
                  itemCount: _propostas.length,
                  itemBuilder: (context, index) {
                    final proposta = _propostas[index];
                    final itemDesejado =
                        proposta.get<ParseObject>('itemDesejado');
                    final itensOfertados =
                        proposta.get<List<dynamic>>('itensOfertados') ?? [];
                    final destinatario =
                        proposta.get<ParseUser>('destinatario');

                    return ListTile(
                      title: Text(
                          'Proposta para ${destinatario?.get<String>('nome') ?? 'Usuário'}'),
                      subtitle: Text(
                        'Você deseja: ${itemDesejado?.get<String>('titulo') ?? 'Item desconhecido'}\n'
                        'Você ofereceu: ${itensOfertados.length} item(ns)',
                      ),
                      trailing: proposta.get<num>('valorEmDinheiro') != null
                          ? Text('R\$ ${proposta.get<num>('valorEmDinheiro')}')
                          : null,
                      onTap: () {
                        // Aqui você pode adicionar navegação para detalhes da proposta
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildListItem(ParseObject item) {
    final titulo = item.get<String>('titulo') ?? 'Item sem título';
    final descricao = item.get<String>('descricao') ?? '';
    final imagemParseFile = item.get<ParseFileBase>('imagem');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF9F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imagemParseFile != null && imagemParseFile.url != null
                ? Image.network(
                    imagemParseFile.url!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.broken_image,
                            color: Colors.grey.shade600),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey.shade600),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                if (descricao.isNotEmpty)
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
          ),
        ],
      ),
    );
  }
}
