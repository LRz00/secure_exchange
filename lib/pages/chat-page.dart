import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'profile-page.dart';

// Definição das cores personalizadas
const Color roxo = Color.fromRGBO(40, 0, 109, 1);
const Color cinzaClaro = Color.fromRGBO(230, 229, 235, 1);
const Color branco = Colors.white;

class ChatPage extends StatefulWidget {
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
  final List<Map<String, dynamic>> _messages = [];
  late Timer _timer;
  late ParseUser _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = await ParseUser.currentUser() as ParseUser;
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser;

      // Query para mensagens enviadas pelo usuário atual para o destinatário
      final QueryBuilder<ParseObject> sentMessagesQuery =
          QueryBuilder<ParseObject>(ParseObject('ChatMessage'))
            ..whereEqualTo('sender', currentUser.toPointer())
            ..whereEqualTo('receiver', widget.destinatario.toPointer())
            ..orderByAscending('createdAt'); // Alterado para orderByAscending

      // Query para mensagens recebidas do destinatário
      final QueryBuilder<ParseObject> receivedMessagesQuery =
          QueryBuilder<ParseObject>(ParseObject('ChatMessage'))
            ..whereEqualTo('sender', widget.destinatario.toPointer())
            ..whereEqualTo('receiver', currentUser.toPointer())
            ..orderByAscending('createdAt'); // Alterado para orderByAscending

      // Executa ambas as queries
      final ParseResponse sentResponse = await sentMessagesQuery.query();
      final ParseResponse receivedResponse =
          await receivedMessagesQuery.query();

      if (sentResponse.success && receivedResponse.success) {
        final List<ParseObject> sentMessages =
            sentResponse.results?.cast<ParseObject>() ?? [];
        final List<ParseObject> receivedMessages =
            receivedResponse.results?.cast<ParseObject>() ?? [];

        // Combina todas as mensagens
        final List<ParseObject> allMessages = [
          ...sentMessages,
          ...receivedMessages
        ];
        // Ordena em ordem crescente (mais antigas primeiro, mais recentes por último)
        allMessages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

        setState(() {
          _messages.clear();
          for (var message in allMessages) {
            _messages.add({
              'text': message.get<String>('content') ?? '',
              'isMe': message.get<ParseObject>('sender')?.objectId ==
                  currentUser.objectId,
              'createdAt': message.createdAt,
            });
          }
        });
      }
    } catch (e) {
      print('Erro ao buscar mensagens: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final currentUser = await ParseUser.currentUser() as ParseUser;

      final ParseObject newMessage = ParseObject('ChatMessage')
        ..set('content', _messageController.text.trim())
        ..set('sender', currentUser.toPointer())
        ..set('receiver', widget.destinatario.toPointer());

      final ParseResponse response = await newMessage.save();

      if (response.success) {
        _messageController.clear();
        await _fetchMessages(); // Atualiza a lista imediatamente
      } else {
        print('Erro ao enviar mensagem: ${response.error?.message}');
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomeDestinatario =
        widget.destinatario.get<String>('nome') ?? 'Usuário';
    final inicial =
        nomeDestinatario.isNotEmpty ? nomeDestinatario[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: branco,
      appBar: AppBar(
        backgroundColor: branco,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.destinatario)),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cinzaClaro,
                child: Text(inicial,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    'online',
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
                ? const Center(child: Text("Envie uma mensagem para começar. Nunca compartilhe informações pessoais com estranhos."))
                : ListView.builder(
                    // Remova o reverse: true
                    padding: const EdgeInsets.all(10.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      // Use o índice diretamente sem inverter
                      final message = _messages[index];
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
                    hintText: 'Mensagem',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: _sendMessage,
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
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
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
