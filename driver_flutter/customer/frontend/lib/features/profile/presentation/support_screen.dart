import 'package:flutter/material.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';
import '../../ride/presentation/in_app_chat_sheet.dart';

class SupportScreen extends StatefulWidget {
  final UserRepository userRepository;

  const SupportScreen({
    super.key,
    required this.userRepository,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<FaqCategory> _faqCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final res = await widget.userRepository.getSupportFaqs();
      if (mounted) {
        setState(() {
          _faqCategories = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1410),
      appBar: AppBar(
        title: const Text('Help & Support Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF161C18),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact Options Banner Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF00C853).withValues(alpha: 0.2), const Color(0xFF161C18)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(0xFF00C853),
                                  child: Icon(Icons.headset_mic_rounded, color: Colors.white, size: 24),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '24/7 Priority Support',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Average response time: < 2 minutes',
                                        style: TextStyle(color: Colors.white60, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) => const InAppChatSheet(
                                          rideId: 'support_ticket',
                                          driverName: 'GoRush Live Support',
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 16),
                                    label: const Text('Live Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00C853),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Dialing GoRush 24/7 Helpline: +91 1800 408 1234...'),
                                          backgroundColor: Color(0xFF00C853),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF00C853), size: 16),
                                    label: const Text('Call Support', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 13)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF00C853)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // FAQ Search Input
                      TextField(
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00C853)),
                          hintText: 'Search FAQ issues (e.g. fare, OTP, schedule)...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFF161C18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('Frequently Asked Questions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      ..._faqCategories.map((cat) {
                        final filteredFaqs = cat.faqs.where((f) {
                          if (_searchQuery.isEmpty) return true;
                          return f.question.toLowerCase().contains(_searchQuery) || f.answer.toLowerCase().contains(_searchQuery);
                        }).toList();

                        if (filteredFaqs.isEmpty) return const SizedBox.shrink();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161C18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text(cat.category, style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const Divider(height: 1, color: Colors.white10),
                              ...filteredFaqs.map((item) {
                                return ExpansionTile(
                                  title: Text(item.question, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  iconColor: const Color(0xFF00C853),
                                  collapsedIconColor: Colors.white54,
                                  children: [
                                    Text(item.answer, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
