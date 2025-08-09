import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'chat-page.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({Key? key}) : super(key: key);

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  List<ParseUser> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserChats();
  }

  Future<void> _fetchUserChats() async {
  try {
    final currentUser = await ParseUser.currentUser() as ParseUser;
    
    // Create two separate queries for sender and receiver
    final QueryBuilder<ParseObject> sentQuery = QueryBuilder<ParseObject>(ParseObject('ChatMessage'))
      ..whereEqualTo('sender', currentUser.toPointer())
      ..orderByDescending('createdAt');

    final QueryBuilder<ParseObject> receivedQuery = QueryBuilder<ParseObject>(ParseObject('ChatMessage'))
      ..whereEqualTo('receiver', currentUser.toPointer())
      ..orderByDescending('createdAt');

    // Execute both queries
    final ParseResponse sentResponse = await sentQuery.query();
    final ParseResponse receivedResponse = await receivedQuery.query();

    if ((sentResponse.success || receivedResponse.success)) {
      final Set<String> uniqueUserIds = {};
      final List<ParseUser> participants = [];

      // Process sent messages
      if (sentResponse.success && sentResponse.results != null) {
        for (var message in sentResponse.results!.cast<ParseObject>()) {
          final receiver = message.get<ParseObject>('receiver');
          if (receiver != null && receiver.objectId != currentUser.objectId && !uniqueUserIds.contains(receiver.objectId)) {
            uniqueUserIds.add(receiver.objectId!);
            participants.add(await receiver.fetch() as ParseUser);
          }
        }
      }

      // Process received messages
      if (receivedResponse.success && receivedResponse.results != null) {
        for (var message in receivedResponse.results!.cast<ParseObject>()) {
          final sender = message.get<ParseObject>('sender');
          if (sender != null && sender.objectId != currentUser.objectId && !uniqueUserIds.contains(sender.objectId)) {
            uniqueUserIds.add(sender.objectId!);
            participants.add(await sender.fetch() as ParseUser);
          }
        }
      }

      setState(() {
        _chats = participants;
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Erro ao buscar chats: $e');
    setState(() => _isLoading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Conversas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? const Center(child: Text('Nenhuma conversa encontrada'))
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final user = _chats[index];
                    final nome = user.get<String>('nome') ?? 'Usuário';
                    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(inicial),
                      ),
                      title: Text(nome),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(destinatario: user),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}