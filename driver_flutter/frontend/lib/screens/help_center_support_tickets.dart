import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';
import '../services/support_chat_service.dart';

class HelpCenterSupportTicketsScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onRaiseTicketTap;
  final VoidCallback? onSafetyTap;
  final Function(int)? onBottomNavTap;

  const HelpCenterSupportTicketsScreen({
    super.key,
    this.onBackTap,
    this.onRaiseTicketTap,
    this.onSafetyTap,
    this.onBottomNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Support Hub',
          style: TextStyle(
            color: QuickServeColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input (Phone 17)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (query) => _showSearchResults(context, query),
                  decoration: InputDecoration(
                    hintText: 'Search help topics, fares, payouts...',
                    hintStyle: TextStyle(
                        color: QuickServeColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: QuickServeColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 5 Support Option Cards (Phone 17)
              _buildSupportCard(
                icon: Icons.help_outline_rounded,
                iconColor: QuickServeColors.primaryBlue,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Help Center & FAQs',
                subtitle:
                    'Find answers to common questions about GoRush trips & earnings',
                onTap: () => _showFaqs(context),
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.chat_rounded,
                iconColor: QuickServeColors.statusGreen,
                iconBg: const Color(0xFFE8F8EE),
                title: 'Live Chat Support',
                subtitle: 'Chat directly with GoRush 24/7 driver support team',
                onTap: () => _showLiveChatSafe(context),
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF3E8FF),
                title: 'Call Driver Helpline',
                subtitle: 'Direct phone helpline: +91 98765 43210 (Toll Free)',
                onTap: () => _callHelpline(context),
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.report_problem_outlined,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Report an Issue',
                subtitle:
                    'Report a fare dispute, toll query, or passenger issue',
                onTap: onRaiseTicketTap ??
                    () {
                      AppToast.info(context, 'Ticket created: Case #GR-9822');
                    },
              ),
              const SizedBox(height: 12),

              _buildSupportCard(
                icon: Icons.health_and_safety_outlined,
                iconColor: QuickServeColors.statusRed,
                iconBg: const Color(0xFFFEF2F2),
                title: 'Safety Guidelines & SOS',
                subtitle:
                    'Emergency protocols, road assistance & insurance coverage',
                onTap: onSafetyTap ??
                    () =>
                        AppToast.info(context, 'Safety Center is unavailable.'),
              ),

              const SizedBox(height: 20),

              // Active Ticket Card
              InkWell(
                onTap: onRaiseTicketTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: QuickServeColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Recent Support Ticket',
                            style: TextStyle(
                              color: QuickServeColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Case #GR-9822',
                            style: TextStyle(
                              color: QuickServeColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toll reimbursement query for Sector 62 expressway',
                        style: TextStyle(
                            color: QuickServeColors.textSecondary,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: QuickServeColors.statusGreenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Resolved • Credited to Wallet',
                          style: TextStyle(
                              color: QuickServeColors.statusGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchResults(BuildContext context, String query) {
    final normalized = query.trim().toLowerCase();
    const topics = [
      'Ride fares and fare disputes',
      'Earnings, cash-out and payout status',
      'Passenger pickup and trip OTP',
      'Safety, SOS and emergency support',
      'Account, documents and verification',
    ];
    final results = normalized.isEmpty
        ? topics
        : topics
            .where((topic) => topic.toLowerCase().contains(normalized))
            .toList();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(normalized.isEmpty ? 'Help topics' : 'Search results'),
        content: SizedBox(
          width: double.maxFinite,
          child: results.isEmpty
              ? const Text(
                  'No matching help topic. Use Report an Issue for personal assistance.')
              : ListView(
                  shrinkWrap: true,
                  children: results
                      .map((topic) => ListTile(
                            leading: const Icon(Icons.article_outlined),
                            title: Text(topic),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              _showFaqs(context, initialTopic: topic);
                            },
                          ))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showFaqs(BuildContext context, {String? initialTopic}) {
    const faqs = [
      (
        'How are fares calculated?',
        'Your fare includes base fare, distance, time, tolls and applicable taxes. Use Report an Issue for a specific trip dispute.'
      ),
      (
        'When do I receive earnings?',
        'Completed ride earnings appear in Earnings and are eligible for payout according to your selected payout method.'
      ),
      (
        'What if OTP does not match?',
        'Ask the passenger to verify the 4-digit trip OTP. Do not start a trip until the OTP is confirmed.'
      ),
      (
        'How do I get emergency help?',
        'Open Safety Guidelines & SOS, share your location, or call Police on 112 for an immediate emergency.'
      ),
    ];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initialTopic ?? 'Help Center & FAQs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: faqs
                .map((faq) => ExpansionTile(title: Text(faq.$1), children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(faq.$2))
                    ]))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showLiveChatSafe(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const _LiveSupportChatSheet(),
    );
  }

  // Kept for source compatibility; Live Chat uses _showLiveChatSafe above.
  // ignore: unused_element
  void _showLiveChat(BuildContext context) {
    final controller = TextEditingController();
    String? sentMessage;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const ListTile(
                leading: CircleAvatar(child: Icon(Icons.support_agent)),
                title: Text('GoRush Driver Support'),
                subtitle: Text('Online • typically replies in a few minutes')),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Hi! Tell us what you need help with.')),
            if (sentMessage != null) ...[
              const SizedBox(height: 12),
              Align(
                  alignment: Alignment.centerRight, child: Text(sentMessage!)),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Thanks—your message is queued for a support agent.')),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'Type your message...'))),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = controller.text.trim();
                    if (message.isEmpty) return;
                    setSheetState(() {
                      sentMessage = message;
                      controller.clear();
                    });
                  }),
            ]),
          ]),
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _callHelpline(BuildContext context) async {
    const number = '+919876543210';
    try {
      final launched = await launchUrl(Uri.parse('tel:$number'),
          mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        AppToast.error(
            context, 'Could not open the dialer. Please call $number.');
      }
    } catch (_) {
      if (context.mounted) {
        AppToast.error(
            context, 'Could not open the dialer. Please call $number.');
      }
    }
  }

  Widget _buildSupportCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: QuickServeColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: QuickServeColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: QuickServeColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: QuickServeColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LiveSupportChatSheet extends StatefulWidget {
  const _LiveSupportChatSheet();

  @override
  State<_LiveSupportChatSheet> createState() => _LiveSupportChatSheetState();
}

class _LiveSupportChatSheetState extends State<_LiveSupportChatSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _sentMessage;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _sending) return;
    setState(() => _sending = true);
    final delivered = await SupportChatService.instance.send(message);
    if (!mounted) return;
    setState(() => _sending = false);
    if (!delivered) {
      AppToast.error(context, 'Message was not sent. Check connection and try again.');
      return;
    }
    setState(() {
      _sentMessage = message;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.support_agent)),
            title: Text('GoRush Driver Support'),
            subtitle: Text('Online \u2022 typically replies in a few minutes'),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Hi! Tell us what you need help with.'),
          ),
          if (_sentMessage != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: Text(_sentMessage!)),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Thanks\u2014your message is queued for a support agent.'),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _send(),
                  decoration:
                      const InputDecoration(hintText: 'Type your message...'),
                ),
              ),
              IconButton(
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: _sending ? null : _send,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
