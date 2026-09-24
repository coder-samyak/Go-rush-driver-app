import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/token_storage_service.dart';
import '../services/support_chat_service.dart';

/// Represents a single message in the Chatbot conversation
class ChatbotMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatbotMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Full-screen modern AI Chatbot screen for GoRush Driver App
/// Designed similar to ChatGPT / Meta AI, matching the GoRush theme.
class DriverChatbotScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const DriverChatbotScreen({
    super.key,
    this.onBackTap,
  });

  @override
  State<DriverChatbotScreen> createState() => _DriverChatbotScreenState();
}

class _DriverChatbotScreenState extends State<DriverChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatbotMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '💰 How are my earnings calculated?',
    '⚡ How does Instant Cash Out work?',
    '🚗 How do I accept incoming rides?',
    '🛡️ What to do in an emergency?',
    '📍 Help with GPS navigation',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialGreeting();
  }

  void _loadInitialGreeting() {
    final profile = TokenStorageService.instance.driverProfile;
    final driverName = profile?['name']?.toString().trim() ?? 'Partner';
    
    _messages.add(
      ChatbotMessage(
        text: 'Hello $driverName! 👋 I am your GoRush Saathi AI assistant.\n\nHow can I help you today? You can ask about your rides, earnings, navigation, or app support.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? predefinedText]) async {
    final text = predefinedText ?? _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    if (predefinedText == null) {
      _textController.clear();
    }

    setState(() {
      _messages.add(
        ChatbotMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Send to backend support service in background (if configured)
    SupportChatService.instance.send(text).ignore();

    // Generate intelligent AI response (Your friend can replace this with LLM API)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final botReply = _getSmartBotResponse(text);

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatbotMessage(
          text: botReply,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();
  }

  String _getSmartBotResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('earning') || q.contains('payout') || q.contains('paise')) {
      return '📊 **Earnings Summary**:\nYour daily earnings are updated after every completed trip. You can view full fare breakdowns in the **Earnings** tab.\n\nFares include base fare + distance + time charges + active peak multipliers.';
    } else if (q.contains('cash out') || q.contains('withdraw')) {
      return '⚡ **Instant Cash Out**:\nYou can transfer your wallet balance directly to your registered bank account via UPI/IMPS instantly from the **Instant Cash Out** button on your home dashboard.';
    } else if (q.contains('ride') || q.contains('accept') || q.contains('trip')) {
      return '🚗 **Ride Dispatch**:\nWhen a ride alert appears, swipe or tap "Accept" within 15 seconds. Ensure you ask the passenger for their 4-digit OTP before starting the ride.';
    } else if (q.contains('emergency') || q.contains('sos') || q.contains('safety') || q.contains('help')) {
      return '🛡️ **Safety & SOS**:\nIn case of an urgent emergency, tap the red **Emergency SOS** button on the Home screen or dial 112 directly. Your live GPS coordinates will be shared with the GoRush 24/7 safety team.';
    } else if (q.contains('navigation') || q.contains('map') || q.contains('gps')) {
      return '📍 **Navigation**:\nTap the Navigation quick circle on your dashboard to view high-demand heatmaps and live turn-by-turn routing.';
    } else {
      return 'Thank you for your question. I am here 24/7 to assist with GoRush rides, fares, and account status. Feel free to choose from the suggestions below or ask any question!';
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _loadInitialGreeting();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Chat message list
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),

            // Quick Prompt Suggestions (shown when few messages)
            if (_messages.length <= 2) _buildQuickPromptsRow(),

            // Bottom Text Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: QuickServeColors.textDark, size: 20),
        onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GoRush Saathi AI',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: QuickServeColors.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Online • AI Partner',
                    style: TextStyle(
                      color: QuickServeColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: QuickServeColors.textSecondary),
          tooltip: 'Reset chat',
          onPressed: _clearChat,
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatbotMessage msg) {
    final isUser = msg.isUser;
    final timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? QuickServeColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: QuickServeColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isUser ? 0.08 : 0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : QuickServeColors.textDark,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: isUser ? Colors.white70 : QuickServeColors.textMuted,
                      fontSize: 9.5,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: QuickServeColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(QuickServeColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Saathi AI is thinking...',
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsRow() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final prompt = _quickPrompts[i];
          return ActionChip(
            label: Text(
              prompt,
              style: const TextStyle(fontSize: 11.5, color: QuickServeColors.primaryBlue),
            ),
            backgroundColor: const Color(0xFFEFF6FF),
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () => _handleSendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: QuickServeColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: QuickServeColors.inputBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: QuickServeColors.borderLight),
              ),
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 13.5, color: QuickServeColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Ask GoRush AI anything...',
                  hintStyle: TextStyle(color: QuickServeColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
              onPressed: _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
