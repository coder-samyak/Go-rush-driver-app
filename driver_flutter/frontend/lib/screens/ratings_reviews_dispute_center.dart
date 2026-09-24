import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';
import '../widgets/safe_avatar.dart';

class RatingsReviewsDisputeScreen extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onDisputeTap;
  final Function(int)? onBottomNavTap;

  const RatingsReviewsDisputeScreen({
    super.key,
    this.onBackTap,
    this.onDisputeTap,
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
          'Ratings & Reviews',
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
              // Rating Overview Card with Crown (Phone 10)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: QuickServeColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Score Column with Trophy/Crown
                    Column(
                      children: [
                        const Icon(Icons.military_tech, color: Color(0xFFFBBF24), size: 30),
                        const SizedBox(height: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                            Icon(Icons.star, color: Color(0xFFFBBF24), size: 16),
                            Icon(Icons.star_half, color: Color(0xFFFBBF24), size: 16),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '120 reviews',
                          style: TextStyle(
                            color: QuickServeColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 24),

                    // Progress Bars (Phone 10: 85%, 10%, 3%, 1%, 1%)
                    Expanded(
                      child: Column(
                        children: [
                          _buildStarBar(5, 0.85),
                          const SizedBox(height: 4),
                          _buildStarBar(4, 0.10),
                          const SizedBox(height: 4),
                          _buildStarBar(3, 0.03),
                          const SizedBox(height: 4),
                          _buildStarBar(2, 0.01),
                          const SizedBox(height: 4),
                          _buildStarBar(1, 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Badges / Compliments
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Driver Badges',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge('⭐ Smooth Driving (98)'),
                        _buildBadge('✨ Clean Car (92)'),
                        _buildBadge('⏱ On-Time Arrival (84)'),
                        _buildBadge('🤝 Polite Behaviour (76)'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Recent Passenger Feedback',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Review 1: Rahul Sharma (5★)
              _buildReviewCard(
                name: 'Rahul Sharma',
                time: '2 hours ago',
                rating: 5,
                comment: 'Great driving, very polite! Reached destination quickly.',
                avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
              ),

              const SizedBox(height: 10),

              // Review 2: Priya Singh (5★)
              _buildReviewCard(
                name: 'Priya Singh',
                time: 'Yesterday',
                rating: 5,
                comment: 'On time pickup, smooth drive and very comfortable car.',
                avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
              ),

              const SizedBox(height: 10),

              // Review 3: Amit Kumar (4★)
              _buildReviewCard(
                name: 'Amit Kumar',
                time: '2 days ago',
                rating: 4,
                comment: 'Clean car and safe ride. AC was running well.',
                avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  AppToast.info(context, 'All 120 reviews loaded.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('View All Reviews', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarBar(int star, double ratio) {
    return Row(
      children: [
        Text(
          '$star',
          style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(ratio * 100).toInt()}%',
          style: const TextStyle(color: QuickServeColors.textMuted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Text(
        label,
        style: const TextStyle(color: QuickServeColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String time,
    required int rating,
    required String comment,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QuickServeColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SafeAvatar(
                imageUrl: avatarUrl,
                radius: 16,
                fallbackText: name.substring(0, 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: QuickServeColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(time, style: const TextStyle(color: QuickServeColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (index) => const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(color: QuickServeColors.textSecondary, fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
