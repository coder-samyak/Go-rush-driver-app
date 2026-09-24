import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/incentive_service.dart';
import '../widgets/app_bottom_nav.dart';

class IncentivesWeeklyQuestsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const IncentivesWeeklyQuestsScreen({
    super.key,
    this.onBackTap,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<IncentivesWeeklyQuestsScreen> createState() =>
      _IncentivesWeeklyQuestsScreenState();
}

class _IncentivesWeeklyQuestsScreenState
    extends State<IncentivesWeeklyQuestsScreen> {
  IncentiveSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadIncentives();
  }

  Future<void> _loadIncentives() async {
    final summary = await IncentiveService.instance.fetch();
    if (mounted && summary != null) setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final weekly = _summary?.weekly;
    final weekend = _summary?.weekend;
    return Scaffold(
      backgroundColor: QuickServeColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Incentives',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Banner: Drive More Earn More with Golden Trophy (Phone 9)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Drive More Earn More',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Complete quests and unlock extra rewards every week!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emoji_events,
                                color: Color(0xFFFBBF24), size: 36),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Title
                    const Text(
                      'Active Quests & Challenges',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card 1: Weekly Challenge • ₹1,000
                    _buildIncentiveCard(
                      title: 'Weekly Challenge',
                      reward: '₹1,000',
                      description: 'Complete 15 trips this week',
                      progress: weekly?.progress ?? 0,
                      progressText:
                          '${weekly?.completed ?? 0} of ${weekly?.target ?? 15} trips completed (${weekly?.status ?? 'In progress'})',
                      accentColor: QuickServeColors.primaryBlue,
                      icon: Icons.flag,
                    ),

                    const SizedBox(height: 12),

                    // Card 2: Weekend Bonus • ₹500
                    _buildIncentiveCard(
                      title: 'Weekend Bonus',
                      reward: '₹500',
                      description: 'Complete 10 trips during Saturday & Sunday',
                      progress: weekend?.progress ?? 0,
                      progressText:
                          '${weekend?.completed ?? 0} of ${weekend?.target ?? 10} trips completed (${weekend?.status ?? 'In progress'})',
                      accentColor: QuickServeColors.statusGreen,
                      icon: Icons.weekend,
                    ),

                    const SizedBox(height: 12),

                    // Card 3: Top Driver • ₹1,500
                    _buildIncentiveCard(
                      title: 'Top Driver',
                      reward: '₹1,500',
                      description: 'Maintain 4.5+ average rating this month',
                      progress: 1.0,
                      progressText: '4.8 ★ / 4.5 Rating (Qualified)',
                      accentColor: const Color(0xFFF59E0B),
                      icon: Icons.star,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Incentives Tab Active: Index 3)
            AppBottomNav(
              currentIndex: 3,
              onTap: (idx) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(idx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveCard({
    required String title,
    required String reward,
    required String description,
    required double progress,
    required String progressText,
    required Color accentColor,
    required IconData icon,
  }) {
    final cardProgress =
        title == 'Top Driver' ? (_summary?.ratingProgress ?? 0.0) : progress;
    final cardProgressText = title == 'Top Driver'
        ? '${(_summary?.rating ?? 0).toStringAsFixed(1)} ★ / ${(_summary?.ratingTarget ?? 4.5).toStringAsFixed(1)} Rating (${_summary?.topDriverStatus ?? 'Not qualified'})'
        : progressText;
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: QuickServeColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: QuickServeColors.statusGreenLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: QuickServeColors.statusGreen, width: 0.8),
                ),
                child: Text(
                  reward,
                  style: const TextStyle(
                    color: QuickServeColors.statusGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: cardProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardProgressText,
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(cardProgress * 100).toInt()}%',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
