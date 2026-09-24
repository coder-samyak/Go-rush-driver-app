import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/app_top_header.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/floating_sos_button.dart';
import '../widgets/safe_avatar.dart';

class PassengerChatPickupScreen extends StatefulWidget {
  final VoidCallback? onCallTap;
  final VoidCallback? onArrivedTap;
  final VoidCallback? onSosTap;
  final Function(int)? onBottomNavTap;

  const PassengerChatPickupScreen({
    super.key,
    this.onCallTap,
    this.onArrivedTap,
    this.onSosTap,
    this.onBottomNavTap,
  });

  @override
  State<PassengerChatPickupScreen> createState() => _PassengerChatPickupScreenState();
}

class _PassengerChatPickupScreenState extends State<PassengerChatPickupScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRushColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 60,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Header
                  AppTopHeader(
                    title: 'PARTNER FLEET\nRadar',
                    isOnline: true,
                  ),
                  // Passenger Info Bar
                  _buildPassengerBar(),
                  // Free Waiting Time Banner
                  _buildWaitingTimeBanner(),
                  // Chat List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      children: [
                        // Car status pill banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101E35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GoRushColors.surfaceBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.directions_car, color: GoRushColors.primaryGreen, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aman is 2 mins away in White Dzire (DL 01 AB 9021)',
                                  style: TextStyle(color: GoRushColors.textSecondary, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Passenger Message
                        _buildPassengerBubble(
                          'Bhaiya main Gate 4 ke bahar khada hoon, yellow pillar ke paas.',
                          '8:42 PM',
                        ),
                        const SizedBox(height: 8),
                        // Driver Message
                        _buildDriverBubble(
                          'Haan ji, 2 minute mein yellow pillar ke samne ruk raha hoon.',
                          '8:43 PM',
                        ),
                        const SizedBox(height: 10),
                        // Photo attachment preview
                        _buildPhotoPreviewCard(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  // Quick reply chips
                  _buildQuickChips(),
                  // Chat Input Row
                  _buildInputBar(),
                ],
              ),
            ),
          ),
          // Floating SOS Button
          if (widget.onSosTap != null)
            FloatingSosButton(
              onTap: widget.onSosTap!,
              bottomOffset: 70,
              rightOffset: 14,
            ),
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNav(
              selectedIndex: 0,
              onTabSelected: (index) {
                if (widget.onBottomNavTap != null) {
                  widget.onBottomNavTap!(index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: const Color(0xFF0C1629),
      child: Row(
        children: [
          const SafeAvatar(
            size: 38,
            initials: 'AV',
            imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Aman Verma',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.star, color: GoRushColors.gold, size: 13),
                    Text(' 4.95', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  '#TRP-8212 · Sedan Premier',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: GoRushColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onArrivedTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: GoRushColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "I've Arrived",
                style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingTimeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF0F2238),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, color: GoRushColors.primaryGreen, size: 15),
              SizedBox(width: 6),
              Text(
                'FREE WAITING: 03:01',
                style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            '₹2.50/min after 5m',
            style: TextStyle(color: GoRushColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF13233E),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          border: Border.all(color: GoRushColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: GoRushColors.textMuted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: GoRushColors.primaryGreen,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Color(0x99000000), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 200,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF13233E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GoRushColors.surfaceBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF162544),
                  child: const Center(
                    child: Icon(Icons.photo, color: GoRushColors.primaryGreen, size: 28),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xB2000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Gate 4 • Pillar 14B', style: TextStyle(color: Colors.white, fontSize: 9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          ActionChip(
            label: const Text('I have arrived', style: TextStyle(fontSize: 11, color: Colors.white)),
            backgroundColor: const Color(0xFF142442),
            side: const BorderSide(color: GoRushColors.surfaceBorder),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ActionChip(
            label: const Text('Heavy traffic, reaching in 2m', style: TextStyle(fontSize: 11, color: Colors.white)),
            backgroundColor: const Color(0xFF142442),
            side: const BorderSide(color: GoRushColors.surfaceBorder),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xFF091223),
      child: Row(
        children: [
          const Icon(Icons.mic, color: GoRushColors.textSecondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF101D35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GoRushColors.surfaceBorder),
              ),
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Message Aman (Hindi/English)...',
                  hintStyle: TextStyle(color: GoRushColors.textMuted, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.camera_alt_outlined, color: GoRushColors.textSecondary, size: 22),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: GoRushColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Colors.black, size: 18),
          ),
        ],
      ),
    );
  }
}
