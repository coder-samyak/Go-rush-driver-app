import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// Bus Screen
// ─────────────────────────────────────────────────────────────────
class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _fromCtrl =
      TextEditingController(text: 'New Delhi');
  final TextEditingController _toCtrl =
      TextEditingController(text: 'Jaipur');
  DateTime _journeyDate = DateTime.now().add(const Duration(days: 2));
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All', 'AC Sleeper', 'Non-AC', 'Volvo', 'Semi-Sleeper', 'Seater',
  ];

  static const List<_BusItem> _buses = [
    _BusItem(
      operator: 'RSRTC Volvo',
      busType: 'AC Volvo Multi Axle',
      from: 'Delhi ISBT',
      to: 'Jaipur Sindhi Camp',
      dep: '06:00',
      arr: '11:00',
      duration: '5h',
      price: 649,
      seatsLeft: 12,
      rating: 4.5,
      tag: 'Upto 25% Off',
      tagColor: Color(0xFF00A651),
      amenities: ['AC', 'WiFi', 'Charging Point', 'Water Bottle'],
      color: Color(0xFF1B5E20),
      busClass: 'AC Sleeper',
    ),
    _BusItem(
      operator: 'IntraBus Express',
      busType: 'AC Semi-Sleeper',
      from: 'Delhi Kashmere Gate',
      to: 'Jaipur',
      dep: '07:30',
      arr: '12:30',
      duration: '5h',
      price: 449,
      seatsLeft: 4,
      rating: 4.2,
      tag: 'Almost Full!',
      tagColor: Color(0xFFE53935),
      amenities: ['AC', 'Charging Point'],
      color: Color(0xFF0288D1),
      busClass: 'Semi-Sleeper',
    ),
    _BusItem(
      operator: 'Raj National Express',
      busType: 'Volvo 9400 AC',
      from: 'Delhi ISBT',
      to: 'Jaipur Sindhi Camp',
      dep: '10:00',
      arr: '15:30',
      duration: '5h 30m',
      price: 749,
      seatsLeft: 18,
      rating: 4.7,
      tag: 'Top Rated',
      tagColor: Color(0xFF7B1FA2),
      amenities: ['AC', 'WiFi', 'Blanket', 'Movie'],
      color: Color(0xFF7B1FA2),
      busClass: 'Volvo',
    ),
    _BusItem(
      operator: 'Rajdhani Travels',
      busType: 'Non-AC Sleeper',
      from: 'Delhi Sarai Kale Khan',
      to: 'Jaipur',
      dep: '22:00',
      arr: '04:30',
      duration: '6h 30m',
      price: 249,
      seatsLeft: 32,
      rating: 3.9,
      tag: 'Budget',
      tagColor: Color(0xFF374151),
      amenities: ['Sleeper Berths'],
      color: Color(0xFF4E342E),
      busClass: 'Non-AC',
    ),
    _BusItem(
      operator: 'Orange Travels',
      busType: 'Luxury AC Seater',
      from: 'Delhi Connaught Place',
      to: 'Jaipur MI Road',
      dep: '08:00',
      arr: '13:00',
      duration: '5h',
      price: 549,
      seatsLeft: 22,
      rating: 4.4,
      tag: 'Popular',
      tagColor: Color(0xFFE65100),
      amenities: ['AC', 'Recliner Seats', 'Refreshments'],
      color: Color(0xFFE65100),
      busClass: 'Seater',
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
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${d.day} ${months[d.month - 1]}, ${days[d.weekday - 1]}';
  }

  void _swapCities() {
    final t = _fromCtrl.text;
    _fromCtrl.text = _toCtrl.text;
    _toCtrl.text = t;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
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
                backgroundColor: const Color(0xFF1B5E20),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _BusHero(
                    fromCtrl: _fromCtrl,
                    toCtrl: _toCtrl,
                    journeyDate: _journeyDate,
                    onDateTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _journeyDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (picked != null) setState(() => _journeyDate = picked);
                    },
                    fmtDate: _fmtDate,
                    onSwap: _swapCities,
                  ),
                ),
                title: const Text(
                  'Bus Tickets',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_filled_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save Big — Upto 25% Off on Bus Tickets',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Powered by redBus | Code: GORUSHBUS',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GORUSHBUS',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
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
                      final sel = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF1B5E20)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: sel
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
                        'Available Buses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_buses.length} buses',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bus Cards ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _BusCard(bus: _buses[index], fmtDate: _fmtDate, date: _journeyDate),
                    childCount: _buses.length,
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
// Bus Hero Banner
// ─────────────────────────────────────────────────────────────────
class _BusHero extends StatelessWidget {
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;
  final DateTime journeyDate;
  final VoidCallback onDateTap;
  final String Function(DateTime) fmtDate;
  final VoidCallback onSwap;

  const _BusHero({
    required this.fromCtrl,
    required this.toCtrl,
    required this.journeyDate,
    required this.onDateTap,
    required this.fmtDate,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A2E0A), Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
          child: Column(
            children: [
              // From / To row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: fromCtrl,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                              Icons.trip_origin_rounded,
                              color: Colors.white70,
                              size: 18),
                          labelText: 'From',
                          labelStyle: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          border: InputBorder.none,
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onSwap,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: toCtrl,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 18),
                          labelText: 'To',
                          labelStyle: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          border: InputBorder.none,
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date picker row
              GestureDetector(
                onTap: onDateTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Journey Date',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          Text(fmtDate(journeyDate),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Search Buses',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bus Data Model
// ─────────────────────────────────────────────────────────────────
class _BusItem {
  final String operator;
  final String busType;
  final String from;
  final String to;
  final String dep;
  final String arr;
  final String duration;
  final int price;
  final int seatsLeft;
  final double rating;
  final String tag;
  final Color tagColor;
  final List<String> amenities;
  final Color color;
  final String busClass;

  const _BusItem({
    required this.operator,
    required this.busType,
    required this.from,
    required this.to,
    required this.dep,
    required this.arr,
    required this.duration,
    required this.price,
    required this.seatsLeft,
    required this.rating,
    required this.tag,
    required this.tagColor,
    required this.amenities,
    required this.color,
    required this.busClass,
  });
}

// ─────────────────────────────────────────────────────────────────
// Bus Card Widget
// ─────────────────────────────────────────────────────────────────
class _BusCard extends StatelessWidget {
  final _BusItem bus;
  final String Function(DateTime) fmtDate;
  final DateTime date;

  const _BusCard(
      {required this.bus, required this.fmtDate, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Checking seats for ${bus.operator}...'),
                backgroundColor: const Color(0xFF1B5E20),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Colored top strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: bus.color,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Operator + Tag + Rating
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: bus.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.directions_bus_filled_rounded,
                              color: bus.color, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bus.operator,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                bus.busType,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bus.tagColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            bus.tag,
                            style: TextStyle(
                              color: bus.tagColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF59E0B), size: 13),
                            const SizedBox(width: 2),
                            Text(
                              '${bus.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    // Route
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bus.dep,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              bus.from,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                bus.duration,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: bus.color,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: bus.color
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Icon(Icons.directions_bus_rounded,
                                      color: bus.color, size: 16),
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: bus.color
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: bus.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              bus.arr,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              bus.to,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    // Amenities
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: bus.amenities
                          .map(
                            (a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FFF4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFFA7F3D0)),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF065F46),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 12),
                    // Price + Seats + Book
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${bus.price}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '${bus.seatsLeft} seats left',
                              style: TextStyle(
                                fontSize: 11,
                                color: bus.seatsLeft <= 5
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF6B7280),
                                fontWeight: bus.seatsLeft <= 5
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: bus.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            'View Seats',
                            style: TextStyle(
                              color: bus.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bus.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
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
