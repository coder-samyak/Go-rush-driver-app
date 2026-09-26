import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/theme/colors.dart';
import '../data/travel_category_data.dart';
import '../domain/models/travel_partner_config.dart';
import 'travel_category_sheet.dart';
import 'hotel_screen.dart';
import 'flight_screen.dart';
import 'bus_screen.dart';
import 'train_screen.dart';
import '../../../core/utils/external_launcher_service.dart';

// ─────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────
class TravelDeal {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String discountLabel;
  final bool isZeroFee;
  final String partner;
  final String imagePath;

  const TravelDeal({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.discountLabel,
    required this.isZeroFee,
    required this.partner,
    this.imagePath = '',
  });

  factory TravelDeal.fromJson(Map<String, dynamic> json) => TravelDeal(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        discountLabel: json['discountLabel'] as String,
        isZeroFee: json['isZeroFee'] as bool? ?? false,
        partner: json['partner'] as String,
        imagePath: json['imagePath'] as String? ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────
// Travel API Service
// ─────────────────────────────────────────────────────────────────
class TravelApiService {
  static const String _baseUrl = 'http://localhost:4000';
  static const String _authToken = 'Bearer gorush_dev_token';

  Future<List<TravelDeal>> fetchDeals() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/travel/deals'),
        headers: {'Authorization': _authToken},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['deals'] as List<dynamic>;
        return list.map((e) => TravelDeal.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    // Fallback static data matching backend
    return _staticDeals;
  }

  static final List<TravelDeal> _staticDeals = const [
    TravelDeal(
      id: 'deal_hotel_001',
      category: 'hotel',
      title: 'Hotel',
      subtitle: 'Best room rates',
      discountLabel: 'Upto 55% Off',
      isZeroFee: false,
      partner: 'Goibibo',
      imagePath: 'assets/images/hotel_card.jpg',
    ),
    TravelDeal(
      id: 'deal_flight_001',
      category: 'flight',
      title: 'Flight',
      subtitle: 'Lowest fare, guaranteed',
      discountLabel: 'Upto ₹4000 Off',
      isZeroFee: false,
      partner: 'Goibibo',
      imagePath: 'assets/images/flight_card.jpg',
    ),
    TravelDeal(
      id: 'deal_bus_001',
      category: 'bus',
      title: 'Bus',
      subtitle: 'Save big on',
      discountLabel: 'Upto 25% Off',
      isZeroFee: false,
      partner: 'redBus',
      imagePath: 'assets/images/bus_card.jpg',
    ),
    TravelDeal(
      id: 'deal_train_001',
      category: 'train',
      title: 'Train',
      subtitle: '',
      discountLabel: 'Zero Service Fee',
      isZeroFee: true,
      partner: 'Confirmtkt',
      imagePath: 'assets/images/train_card.jpg',
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────
// TravelScreen — Main Widget
// ─────────────────────────────────────────────────────────────────
class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen>
    with SingleTickerProviderStateMixin {
  final TravelApiService _apiService = TravelApiService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<TravelDeal> _deals = TravelApiService._staticDeals;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    setState(() => _isLoading = true);
    final deals = await _apiService.fetchDeals();
    if (mounted) {
      setState(() {
        _deals = deals;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Category meta helpers ───────────────────────────────────────
  IconData _iconFor(String category) {
    switch (category) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'bus':
        return Icons.directions_bus_filled_rounded;
      case 'train':
        return Icons.train_rounded;
      default:
        return Icons.travel_explore_rounded;
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'hotel':
        return const Color(0xFF1565C0);
      case 'flight':
        return const Color(0xFF0288D1);
      case 'bus':
        return const Color(0xFF388E3C);
      case 'train':
        return const Color(0xFF5E35B1);
      default:
        return GoRushColors.primary;
    }
  }

  void _onDealTap(TravelDeal deal) {
    Widget screen;
    switch (deal.category) {
      case 'hotel':
        screen = const HotelScreen();
        break;
      case 'flight':
        screen = const FlightScreen();
        break;
      case 'bus':
        screen = const BusScreen();
        break;
      case 'train':
        screen = const TrainScreen();
        break;
      default:
        // Fallback: show bottom sheet for unknown categories
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _DealDetailSheet(deal: deal, iconFor: _iconFor, colorFor: _colorFor),
        );
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Hero SliverAppBar ──────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFF0D47A1),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroBanner(screenWidth: size.width),
                  collapseMode: CollapseMode.pin,
                ),
                title: const Text(
                  'Travel & Hotel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),

              // ── 2. Deals Grid ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Travel & Hotel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GoRushColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final deal = _deals[index];
                      return _DealCard(
                        deal: deal,
                        icon: _iconFor(deal.category),
                        accentColor: _colorFor(deal.category),
                        onTap: () => _onDealTap(deal),
                      );
                    },
                    childCount: _deals.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                ),
              ),

              // ── 3. Explore More Row ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Explore More',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      _ExploreChip(label: '🏖️ Beach', tag: 'beach'),
                      _ExploreChip(label: '🏔️ Mountains', tag: 'mountains'),
                      _ExploreChip(label: '🏛️ Heritage', tag: 'heritage'),
                      _ExploreChip(label: '🌆 City Break', tag: 'city'),
                      _ExploreChip(label: '🎡 Weekend', tag: 'weekend'),
                    ],
                  ),
                ),
              ),

              // ── 4. Partners Banner ────────────────────────────────
              SliverToBoxAdapter(
                child: _PartnersBanner(),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero Banner Widget
// ─────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final double screenWidth;
  const _HeroBanner({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          'assets/images/gorush_travel_banner.jpg',
          fit: BoxFit.cover,
        ),
        // Dark gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xDD0D47A1),
                Color(0x990D47A1),
                Color(0x220D47A1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 28),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFF176)],
                  ).createShader(bounds),
                  child: const Text(
                    'Summer Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Text(
                  'ONBOARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'GORUSHTRAVEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use code at checkout',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Deal Card Widget
// ─────────────────────────────────────────────────────────────────
class _DealCard extends StatelessWidget {
  final TravelDeal deal;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _DealCard({
    required this.deal,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        image: deal.imagePath.isNotEmpty
            ? DecorationImage(
                image: AssetImage(deal.imagePath),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient overlay to make text readable
              if (deal.imagePath.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: deal.isZeroFee
                            ? const Color(0xFF5E35B1)
                            : const Color(0xFF00A651),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer_rounded,
                              color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              deal.discountLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    if (deal.subtitle.isNotEmpty)
                      Text(
                        deal.subtitle,
                        style: TextStyle(
                          color: deal.imagePath.isNotEmpty
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                          fontSize: 11,
                        ),
                      ),
                    // Title with arrow
                    Row(
                      children: [
                        Text(
                          deal.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: deal.imagePath.isNotEmpty
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            size: 16,
                            color: deal.imagePath.isNotEmpty
                                ? Colors.white70
                                : const Color(0xFF6B7280)),
                      ],
                    ),
                    const Spacer(),
                    // Category icon — bottom right
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: deal.imagePath.isNotEmpty
                              ? accentColor.withValues(alpha: 0.8)
                              : accentColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon,
                            color: deal.imagePath.isNotEmpty
                                ? Colors.white
                                : accentColor,
                            size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Deal Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────
class _DealDetailSheet extends StatelessWidget {
  final TravelDeal deal;
  final IconData Function(String) iconFor;
  final Color Function(String) colorFor;

  const _DealDetailSheet({
    required this.deal,
    required this.iconFor,
    required this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorFor(deal.category);
    final icon = iconFor(deal.category);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 16, offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            deal.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: deal.isZeroFee
                  ? const Color(0xFF5E35B1).withValues(alpha: 0.1)
                  : const Color(0xFF00A651).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              deal.discountLabel,
              style: TextStyle(
                color: deal.isZeroFee ? const Color(0xFF5E35B1) : const Color(0xFF00A651),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.business_rounded, 'Powered by', deal.partner, color),
          const SizedBox(height: 10),
          if (deal.subtitle.isNotEmpty)
            _infoRow(Icons.local_offer_outlined, 'Deal', deal.subtitle, color),
          const SizedBox(height: 20),
          // CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Explore ${deal.title}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Explore Chip Widget
// ─────────────────────────────────────────────────────────────────
class _ExploreChip extends StatelessWidget {
  final String label;
  final String tag;
  const _ExploreChip({required this.label, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        elevation: 1.5,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: () {
            final config = TravelCategoryData.categories[tag];
            if (config != null) {
              TravelCategorySheet.show(context, config);
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label packages coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF111827),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Partners Banner Widget
// ─────────────────────────────────────────────────────────────────
class _PartnersBanner extends StatelessWidget {
  const _PartnersBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '— Powered by —',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _partnerLogo(context, 'Goibibo', const Color(0xFF1565C0), Icons.hotel_rounded),
              _divider(),
              _partnerLogo(context, 'redBus', const Color(0xFFD32F2F), Icons.directions_bus_rounded),
              _divider(),
              _partnerLogo(context, 'Confirmtkt', const Color(0xFF388E3C), Icons.train_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 28,
        width: 1,
        color: Colors.grey[200],
      );

  Widget _partnerLogo(BuildContext context, String name, Color color, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final partnerConfig = TravelPartnerConfig.partners[name];
          if (partnerConfig == null || !partnerConfig.enabled) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$name is temporarily unavailable.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Continue to $name?'),
              content: Text("You're leaving GoRush to continue with $name."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          final launched = await ExternalLauncherService.launchExternalUrl(partnerConfig.url);
          if (!launched) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Unable to open travel partner right now.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
