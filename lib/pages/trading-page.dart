// lib/pages/trading_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'select-my-item-page.dart';
import 'save-object.dart';

const Color primaryColor = Color.fromRGBO(40, 0, 109, 1);
const Color contrastColor = Colors.white;

class TradingPage extends StatefulWidget {
  final ParseObject itemDesejado;
  const TradingPage({Key? key, required this.itemDesejado}) : super(key: key);

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  final List<ParseObject> itensOfertados = [];
  double valorEmDinheiro = 0.0;
  final TextEditingController _moneyController = TextEditingController();

  Future<void> _adicionarItem() async {
    final itemSelecionado = await Navigator.push<ParseObject>(
      context,
      MaterialPageRoute(builder: (context) => const SelectMyItemPage()),
    );
    if (itemSelecionado != null) {
      setState(() {
        itensOfertados.add(itemSelecionado);
      });
    }
  }

  void _removerItem(int index) {
    setState(() {
      itensOfertados.removeAt(index);
    });
  }

  Future<void> _cadastrarNovoItem() async {
    // Navega para a tela de cadastro e aguarda um resultado
    final novoItem = await Navigator.push<ParseObject>(
      context,
      MaterialPageRoute(builder: (context) => SalvarObjetoPage()),
    );

    // Se o usuário salvou um novo item (e não apenas voltou)
    if (novoItem != null) {
      setState(() {
        // Adiciona o novo item diretamente na lista da oferta
        itensOfertados.add(novoItem);
      });
    }
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Propor Troca'),
      ),
      // NOVO: A barra de botões agora fica aqui, fixa no rodapé
      bottomNavigationBar: _buildBottomActionBar(),

      // ALTERADO: O corpo agora é uma lista simples e rolável
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Item que você receberá:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildItemCard(widget.itemDesejado),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                    child: Icon(Icons.swap_vert, size: 40, color: Colors.grey)),
              ),
              const Text('Sua oferta:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAreaDaOferta(),
              const SizedBox(height: 24), // Espaço extra no final do scroll
            ],
          ),
        ),
      ),
    );
  }

  // Widget de card de item (sem alterações)
  Widget _buildItemCard(ParseObject item) {
    final imagem = item.get<ParseFileBase>('imagem');
    final titulo = item.get<String>('titulo') ?? 'Item';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: (imagem != null && imagem.url != null)
                    ? DecorationImage(
                        image: NetworkImage(imagem.url!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (imagem == null || imagem.url == null)
                  ? Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Área de oferta (com a correção anterior já aplicada)
  Widget _buildAreaDaOferta() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (itensOfertados.isEmpty && valorEmDinheiro == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Adicione itens ou dinheiro à sua oferta abaixo.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          if (itensOfertados.isNotEmpty)
            Column(
              children: itensOfertados.map((item) {
                final index = itensOfertados.indexOf(item);
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: _buildItemCard(item),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _removerItem(index),
                        child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                color: Colors.white, size: 16)),
                      ),
                    )
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _moneyController,
            onChanged: (value) =>
                setState(() => valorEmDinheiro = double.tryParse(value) ?? 0.0),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              labelText: 'Valor em dinheiro (opcional)',
              border: const OutlineInputBorder(),
              suffixIcon: _moneyController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                            _moneyController.clear();
                            valorEmDinheiro = 0;
                          }))
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: _adicionarItem,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Item'))),
              const SizedBox(width: 12),
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: _cadastrarNovoItem,
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text('Cadastrar Novo'))),
            ],
          )
        ],
      ),
    );
  }

  // NOVO: Widget para a barra de botões inferior
  Widget _buildBottomActionBar() {
    final isOfferEmpty = itensOfertados.isEmpty && valorEmDinheiro == 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 24), // Padding para não colar na borda
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isOfferEmpty
                  ? null
                  : () async {
                      ParseUser? usuarioAtual =
                          await ParseUser.currentUser() as ParseUser?;
                      if (usuarioAtual != null) {
                        await usuarioAtual.fetch();
                      }

                      final donoDoItem = widget.itemDesejado.get<ParseUser>('dono');

                      if (usuarioAtual == null || donoDoItem == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Erro: não foi possível identificar os usuários.')),
                        );
                        return;
                      }

                      final proposta = ParseObject('PropostaTroca')
                        ..set('remetente', usuarioAtual)
                        ..set('destinatario', donoDoItem)
                        ..set('itemDesejado', widget.itemDesejado)
                        ..set('itensOfertados', itensOfertados)
                        ..set('valorEmDinheiro', valorEmDinheiro)
                        ..set('status', 'pendente');

                      final response = await proposta.save();
                      if (response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Proposta enviada com sucesso!')),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Erro: ${response.error?.message}')),
                        );
                      }
                    },
              child: const Text('Confirmar Troca'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: primaryColor,
                  foregroundColor: contrastColor,
                  disabledBackgroundColor: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
