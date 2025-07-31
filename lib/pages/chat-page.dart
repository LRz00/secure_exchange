import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'profile-page.dart';

// Definição das cores personalizadas com base no RGB fornecido
const Color roxo = Color.fromRGBO(40, 0, 109, 1);
const Color cinzaClaro = Color.fromRGBO(230, 229, 235, 1);
const Color branco = Colors.white;

class ChatPage extends StatefulWidget {
  // ALTERAÇÃO 1: A página agora precisa receber o usuário destinatário.
  final ParseUser destinatario;

  const ChatPage({
    super.key,
    required this.destinatario,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // ALTERAÇÃO 2: A lista de mensagens agora começa vazia.
  // Você deverá carregar as mensagens da conversa aqui.
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Você pode chamar uma função aqui para carregar as mensagens da conversa
    // ex: _carregarMensagens();
  }

  @override
  Widget build(BuildContext context) {
    // Pega o nome e a inicial do destinatário para usar na AppBar
    final nomeDestinatario = widget.destinatario.get<String>('nome') ?? 'Usuário';
    final inicial = nomeDestinatario.isNotEmpty ? nomeDestinatario[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: branco,
      appBar: AppBar(
        backgroundColor: branco,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ALTERAÇÃO 3: O título agora é dinâmico com os dados do destinatário.
        title: GestureDetector(
          onTap: () {
            // Se a ProfilePage também precisar do usuário, passe-o aqui
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.destinatario)),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cinzaClaro,
                child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomeDestinatario,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'online', // Você pode deixar isso ou adaptar para um status real
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
              ? const Center(child: Text("Envie uma mensagem para começar."))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    return _MessageBubble(
                      text: message['text'],
                      isMe: message['isMe'],
                    );
                  },
                ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    // Nenhuma alteração aqui...
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: branco,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: branco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cinzaClaro),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    hintText: 'Menssagem',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                // Lógica para enviar a mensagem para o destinatário
                print('Mensagem enviada: ${_messageController.text}');
                _messageController.clear();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: roxo,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: branco),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  // Nenhuma alteração aqui...
  final String text;
  final bool isMe;

  const _MessageBubble({
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? roxo : cinzaClaro,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? branco : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}