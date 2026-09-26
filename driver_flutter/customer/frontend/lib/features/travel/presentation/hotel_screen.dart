import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// Hotel Screen
// ─────────────────────────────────────────────────────────────────
class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _cityController =
      TextEditingController(text: 'New Delhi');
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  int _guests = 2;
  int _rooms = 1;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All', 'Under ₹2000', 'Pool', '4★+', 'Free Breakfast', 'Business',
  ];

  static const List<_HotelItem> _hotels = [
    _HotelItem(
      name: 'The Grand Metropolis',
      location: 'Connaught Place, Delhi',
      price: 4299,
      rating: 4.8,
      reviews: 1243,
      stars: 5,
      tag: 'Best Seller',
      tagColor: Color(0xFFE67E22),
      amenities: ['Pool', 'Spa', 'Free WiFi', 'Breakfast'],
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      icon: Icons.hotel_rounded,
    ),
    _HotelItem(
      name: 'Bloom Boutique Stay',
      location: 'Hauz Khas, Delhi',
      price: 1899,
      rating: 4.6,
      reviews: 876,
      stars: 4,
      tag: 'Upto 55% Off',
      tagColor: Color(0xFF00A651),
      amenities: ['Free WiFi', 'Breakfast', 'AC'],
      gradient: [Color(0xFF00796B), Color(0xFF4DB6AC)],
      icon: Icons.villa_rounded,
    ),
    _HotelItem(
      name: 'Sky Tower Suites',
      location: 'Aerocity, Delhi',
      price: 6799,
      rating: 4.9,
      reviews: 2104,
      stars: 5,
      tag: 'Premium',
      tagColor: Color(0xFF7B1FA2),
      amenities: ['Rooftop Pool', 'Gym', 'Spa', 'Club Lounge'],
      gradient: [Color(0xFF283593), Color(0xFF5C6BC0)],
      icon: Icons.apartment_rounded,
    ),
    _HotelItem(
      name: 'Cozy Nest Inn',
      location: 'Lajpat Nagar, Delhi',
      price: 1199,
      rating: 4.3,
      reviews: 512,
      stars: 3,
      tag: 'Great Value',
      tagColor: Color(0xFF388E3C),
      amenities: ['Free WiFi', 'AC', 'Parking'],
      gradient: [Color(0xFF4E342E), Color(0xFF8D6E63)],
      icon: Icons.cottage_rounded,
    ),
    _HotelItem(
      name: 'Regalia Palace Hotel',
      location: 'Lutyens Delhi',
      price: 9999,
      rating: 5.0,
      reviews: 687,
      stars: 5,
      tag: 'Luxury',
      tagColor: Color(0xFFB8860B),
      amenities: ['Pool', 'Spa', 'Fine Dining', 'Butler'],
      gradient: [Color(0xFF880E4F), Color(0xFFF48FB1)],
      icon: Icons.castle_rounded,
    ),
    _HotelItem(
      name: 'Urban Nest Express',
      location: 'Dwarka, Delhi',
      price: 899,
      rating: 4.1,
      reviews: 321,
      stars: 3,
      tag: 'Budget Pick',
      tagColor: Color(0xFF0288D1),
      amenities: ['Free WiFi', 'AC'],
      gradient: [Color(0xFF37474F), Color(0xFF78909C)],
      icon: Icons.bed_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day} ${_months[d.month - 1].substring(0, 3)}';
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero SliverAppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _HotelHero(
                    checkIn: _checkIn,
                    checkOut: _checkOut,
                    guests: _guests,
                    rooms: _rooms,
                    cityController: _cityController,
                    onGuestsChanged: (v) => setState(() => _guests = v),
                    onRoomsChanged: (v) => setState(() => _rooms = v),
                    onCheckInTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _checkIn,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _checkIn = picked;
                          if (_checkOut.isBefore(picked)) {
                            _checkOut = picked.add(const Duration(days: 1));
                          }
                        });
                      }
                    },
                    onCheckOutTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _checkOut,
                        firstDate: _checkIn.add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _checkOut = picked);
                      }
                    },
                    fmt: _fmt,
                  ),
                ),
                title: const Text(
                  'Hotels',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),

              // ── Discount Banner ───────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upto 55% Off on Best Room Rates',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Use code GORUSHHOTEL at checkout',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GORUSHHOTEL',
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter Chips ──────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    itemCount: _filters.length,
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final selected = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1565C0)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF374151),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Section Header ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Featured Hotels',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_hotels.length} properties',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Hotel Cards ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _HotelCard(
                      hotel: _hotels[index],
                      checkIn: _checkIn,
                      checkOut: _checkOut,
                      guests: _guests,
                      fmt: _fmt,
                    ),
                    childCount: _hotels.length,
                  ),
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
// Hotel Hero Banner
// ─────────────────────────────────────────────────────────────────
class _HotelHero extends StatelessWidget {
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final TextEditingController cityController;
  final ValueChanged<int> onGuestsChanged;
  final ValueChanged<int> onRoomsChanged;
  final VoidCallback onCheckInTap;
  final VoidCallback onCheckOutTap;
  final String Function(DateTime) fmt;

  const _HotelHero({
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.cityController,
    required this.onGuestsChanged,
    required this.onRoomsChanged,
    required this.onCheckInTap,
    required this.onCheckOutTap,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Where to stay?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              // City Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: cityController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_rounded,
                        color: Color(0xFF1565C0), size: 20),
                    suffixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF6B7280)),
                    border: InputBorder.none,
                    hintText: 'City, area or hotel name',
                    hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 14),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Check-in / Check-out / Guests Row
              Row(
                children: [
                  Expanded(
                    child: _HeroDateBox(
                      label: 'Check-in',
                      date: fmt(checkIn),
                      onTap: onCheckInTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroDateBox(
                      label: 'Check-out',
                      date: fmt(checkOut),
                      onTap: onCheckOutTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HeroCounterBox(
                    label: 'Guests',
                    value: guests,
                    onChanged: onGuestsChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroDateBox extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  const _HeroDateBox(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 2),
            Text(date,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _HeroCounterBox extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _HeroCounterBox(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 2),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (value > 1) onChanged(value - 1);
                },
                child: const Icon(Icons.remove_circle_outline,
                    color: Colors.white70, size: 16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('$value',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.add_circle_outline,
                    color: Colors.white70, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hotel Data Model
// ─────────────────────────────────────────────────────────────────
class _HotelItem {
  final String name;
  final String location;
  final int price;
  final double rating;
  final int reviews;
  final int stars;
  final String tag;
  final Color tagColor;
  final List<String> amenities;
  final List<Color> gradient;
  final IconData icon;

  const _HotelItem({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.stars,
    required this.tag,
    required this.tagColor,
    required this.amenities,
    required this.gradient,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────
// Hotel Card Widget
// ─────────────────────────────────────────────────────────────────
class _HotelCard extends StatelessWidget {
  final _HotelItem hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String Function(DateTime) fmt;

  const _HotelCard({
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final nights = checkOut.difference(checkIn).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${hotel.name}...'),
                backgroundColor: const Color(0xFF1565C0),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hotel.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Icon(hotel.icon,
                            color: Colors.white.withValues(alpha: 0.25),
                            size: 80),
                      ),
                      // Tag
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: hotel.tagColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            hotel.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Stars
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: List.generate(
                            hotel.stars,
                            (_) => const Icon(Icons.star_rounded,
                                color: Color(0xFFFFD54F), size: 14),
                          ),
                        ),
                      ),
                      // Rating badge
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFD54F), size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '${hotel.rating}  (${hotel.reviews})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Color(0xFF6B7280)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Amenities
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: hotel.amenities
                          .map(
                            (a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFFBFD4FF)),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${hotel.price.toStringAsFixed(0)}/night',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '₹${(hotel.price * nights).toStringAsFixed(0)} for $nights nights · $guests guest${guests > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
