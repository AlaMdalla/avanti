import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../models/message.dart';
import '../services/MessageService.dart';
import '../../profile/services/ProfileService.dart';
import '../../../core/theme/app_theme.dart';
import '../services/ai_bot.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId; // use 'bot' to chat with AI bot

  const ChatScreen({Key? key, required this.currentUserId, required this.otherUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final ProfileService _profileService = ProfileService();
  final TextEditingController _controller = TextEditingController();
  final AiBot _aiBot = AiBot();
  List<Message> _messages = [];
  String _otherUserName = 'User';
  String? _otherUserAvatarUrl;
  bool _loadingAi = false;

  bool get _isBotChat => widget.otherUserId == 'bot';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    if (!_isBotChat) {
      _listenForMessages();
      _loadUserName();
    } else {
      setState(() {
        _otherUserName = 'Avanti Bot';
        _otherUserAvatarUrl = null;
      });
    }
  }

  void _loadMessages() async {
    if (_isBotChat) return; // local-only for bot
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
      _otherUserName = profile?.pseudo?.isNotEmpty == true
          ? profile!.pseudo!
          : '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim().isNotEmpty
              ? '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim()
              : 'User';
      _otherUserAvatarUrl = profile?.avatarUrl;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_isBotChat) {
      setState(() {
        _messages = [..._messages, Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: widget.currentUserId,
          receiverId: 'bot',
          content: text,
          timestamp: DateTime.now(),
        )];
        _loadingAi = true;
      });
      _controller.clear();

      try {
        final history = _messages.map((m) => {
          'role': m.senderId == widget.currentUserId ? 'user' : 'assistant',
          'content': m.content,
        }).toList();
        final reply = await _aiBot.reply(history.cast<Map<String, String>>());
        if (!mounted) return;
        setState(() {
          _messages = [..._messages, Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'bot',
            receiverId: widget.currentUserId,
            content: reply.isEmpty ? '...' : reply,
            timestamp: DateTime.now(),
          )];
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI error: $e')));
      } finally {
        if (mounted) setState(() => _loadingAi = false);
      }
      return;
    }

    // normal user-to-user message
    await _messageService.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      content: text,
    );
    _controller.clear();
    _loadMessages();
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmojiPicker(
        onEmojiSelected: (category, emoji) {
          setState(() {
            _controller.text += emoji.emoji;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shadowColor: AppColors.primary.withOpacity(0.4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surface,
              backgroundImage: _otherUserAvatarUrl != null ? NetworkImage(_otherUserAvatarUrl!) : null,
              child: _otherUserAvatarUrl == null
                  ? Text(
                      _otherUserName.isNotEmpty ? _otherUserName[0].toUpperCase() : '?',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              _isBotChat ? 'Avanti Bot' : _otherUserName,
              style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
            ),
            if (_loadingAi) ...[
              const SizedBox(width: 8),
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ]
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              reverse: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isCurrentUser = message.senderId == widget.currentUserId;
                return Align(
                  alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: isCurrentUser
                          ? LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                          : LinearGradient(
                              colors: [AppColors.surfaceVariant, AppColors.surfaceVariant.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isCurrentUser ? const Radius.circular(18) : Radius.zero,
                        bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(18),
                      ),
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
                        const SizedBox(height: 4),
                        Text(
                          '${isCurrentUser ? 'You' : (_isBotChat ? 'Avanti Bot' : _otherUserName)} • ${message.timestamp}',
                          style: AppTextStyles.caption.copyWith(
                            color: isCurrentUser ? AppColors.textOnPrimary.withOpacity(0.8) : AppColors.textTertiary,
                            fontSize: 10,
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [AppShadows.soft],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.emoji_emotions_outlined, color: AppColors.primary),
                    onPressed: _showEmojiPicker,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(Icons.send_rounded, color: AppColors.textOnPrimary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
