import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../services/MessageService.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatScreen({Key? key, required this.currentUserId, required this.otherUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenForMessages();
  }

  void _loadMessages() async {
    final messages = await _messageService.getMessages(widget.currentUserId, widget.otherUserId);
    setState(() {
      _messages = messages;
    });
  }

  void _listenForMessages() {
    _messageService.listenForMessages(widget.currentUserId, widget.otherUserId).listen((messages) {
      setState(() {
        _messages = messages;
      });
    });
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await _messageService.sendMessage(
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        content: _controller.text,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.otherUserId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text('${message.senderId} - ${message.timestamp}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}