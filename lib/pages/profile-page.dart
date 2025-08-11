import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserItems();
    _loadNegociacoes();
    _loadPropostas();
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
          // O cabeçalho com avatar e nome agora fica na AppBar
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
          // Adiciona a barra de abas na parte inferior da AppBar
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color.fromRGBO(40, 0, 109, 1),
            tabs: [
              Tab(text: 'MEUS ITENS'),
              Tab(text: 'NEGOCIAÇÕES'),
              Tab(text: 'PROPOSTAS'),
            ],
          ),
        ),
        // O corpo agora é uma TabBarView para exibir o conteúdo de cada aba
        body: TabBarView(
          children: [
            _buildMeusItensTab(),
            _buildNegociacoesTab(),
            _buildPropostasTab(),
          ],
        ),
        // Sua BottomNavigationBar original
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
      ),
    );
  }

  // Constrói o conteúdo da primeira aba "Meus Itens"
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

  // Constrói o conteúdo da aba "Negociações"
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

  // Constrói o conteúdo da aba "Propostas"

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

  // Constrói cada card de item da lista
  Widget _buildListItem(ParseObject item) {
    final titulo = item.get<String>('titulo') ?? 'Item sem título';
    final descricao = item.get<String>('descricao') ?? '';
    // NOVO: Busca a imagem do objeto Parse
    final imagemParseFile = item.get<ParseFileBase>('imagem');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding:
          const EdgeInsets.all(12), // Reduzido o padding para acomodar a imagem
      decoration: BoxDecoration(
          color: const Color(0xFFF9F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      // ALTERADO: Usamos uma Row para colocar a imagem ao lado do texto
      child: Row(
        children: [
          // Widget da Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imagemParseFile != null && imagemParseFile.url != null
                // Se tiver imagem, mostra
                ? Image.network(
                    imagemParseFile.url!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    // Adiciona um placeholder enquanto carrega
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // Adiciona tratamento de erro
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
                // Se não tiver imagem, mostra um placeholder
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey.shade600),
                  ),
          ),

          const SizedBox(width: 16), // Espaçamento entre a imagem e o texto

          // Coluna do Texto
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
