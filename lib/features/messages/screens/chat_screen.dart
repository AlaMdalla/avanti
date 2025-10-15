import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../services/MessageService.dart';
import '../../profile/services/ProfileService.dart';
import '../../../core/theme/app_theme.dart';  // Import for AppColors and AppTextStyles

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatScreen({Key? key, required this.currentUserId, required this.otherUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  String _otherUserName = 'User';
  String? _otherUserAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenForMessages();
    _loadUserName();
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

  void _loadUserName() async {
    final profile = await _profileService.getProfile(widget.otherUserId);
    setState(() {
      _otherUserName = profile?.pseudo ?? '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim() ?? 'User';
      _otherUserAvatarUrl = profile?.avatarUrl;
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
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: _otherUserAvatarUrl != null ? NetworkImage(_otherUserAvatarUrl!) : null,
          child: _otherUserAvatarUrl == null ? Text(_otherUserName[0].toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary)) : null,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          radius: 16,
        ),
        title: Text('Chat with $_otherUserName', style: AppTextStyles.h4),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.senderId == widget.currentUserId;
                return Align(
                  alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [AppShadows.soft],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isCurrentUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${isCurrentUser ? 'You' : _otherUserName} • ${message.timestamp}',
                          style: AppTextStyles.caption.copyWith(
                            color: isCurrentUser ? AppColors.textOnPrimary.withOpacity(0.7) : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [AppShadows.soft],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: AppTextStyles.bodySmall,
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    padding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}