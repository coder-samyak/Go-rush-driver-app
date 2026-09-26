import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';

class InAppChatSheet extends StatefulWidget {
  final String rideId;
  final String driverName;

  const InAppChatSheet({
    super.key,
    required this.rideId,
    this.driverName = 'Ramesh Kumar',
  });

  @override
  State<InAppChatSheet> createState() => _InAppChatSheetState();
}

class _InAppChatSheetState extends State<InAppChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'DRIVER',
      'text': 'Hello! I am heading towards your pickup location now.',
      'time': 'Just now',
    },
  ];

  final List<String> _chatPresets = [
    '📍 I am at the pickup location',
    '🚗 Which car color/model?',
    '🚪 Coming down in 1 minute',
    '🚦 Trapped in traffic',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'CUSTOMER',
        'text': text,
        'time': 'Just now',
      });
      if (presetText == null) _messageController.clear();
    });

    // Simulate driver reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'DRIVER',
            'text': 'Got it! See you shortly.',
            'time': 'Just now',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 580),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(GoRushSpacing.md),
        child: Column(
          children: [
            // Handle Drag Line
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: GoRushColors.primary,
                  radius: 18,
                  child: Text(widget.driverName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat with ${widget.driverName}', style: GoRushTypography.h4.copyWith(fontWeight: FontWeight.bold)),
                      const Text('🔒 Masked Private Chat', style: TextStyle(fontSize: 10, color: GoRushColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const Divider(height: 20),

            // Messages Stream
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isCustomer = msg['sender'] == 'CUSTOMER';
                  return Align(
                    alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isCustomer ? const Color(0xFF00C853) : Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                          bottomRight: Radius.circular(isCustomer ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isCustomer ? Colors.white : GoRushColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            msg['time'],
                            style: TextStyle(
                              fontSize: 9,
                              color: isCustomer ? Colors.white70 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Preset Quick Response Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: _chatPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      label: Text(preset, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onPressed: () => _sendMessage(preset),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: GoRushColors.primary)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: GoRushColors.primary,
                  radius: 20,
                  child: IconButton(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
