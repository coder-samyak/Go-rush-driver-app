import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// Flight Screen
// ─────────────────────────────────────────────────────────────────
class FlightScreen extends StatefulWidget {
  const FlightScreen({super.key});

  @override
  State<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _fromCtrl =
      TextEditingController(text: 'DEL – New Delhi');
  final TextEditingController _toCtrl =
      TextEditingController(text: 'BOM – Mumbai');
  DateTime _departure = DateTime.now().add(const Duration(days: 3));
  int _passengers = 1;
  String _tripType = 'One Way';
  String _cabinClass = 'Economy';
  String _selectedAirline = 'All Airlines';

  final List<String> _tripTypes = ['One Way', 'Round Trip', 'Multi-City'];
  final List<String> _cabinClasses = ['Economy', 'Business', 'First'];
  final List<String> _airlineFilters = [
    'All Airlines', 'IndiGo', 'Air India', 'SpiceJet', 'Vistara',
  ];

  static const List<_FlightItem> _flights = [
    _FlightItem(
      airline: 'IndiGo',
      flightNo: '6E 2048',
      from: 'DEL',
      to: 'BOM',
      dep: '06:15',
      arr: '08:30',
      duration: '2h 15m',
      stops: 0,
      price: 3849,
      tag: 'Upto ₹4000 Off',
      tagColor: Color(0xFF00A651),
      color: Color(0xFF1A237E),
      airlineCode: '6E',
    ),
    _FlightItem(
      airline: 'Air India',
      flightNo: 'AI 123',
      from: 'DEL',
      to: 'BOM',
      dep: '09:45',
      arr: '12:00',
      duration: '2h 15m',
      stops: 0,
      price: 5249,
      tag: 'Flex Fare',
      tagColor: Color(0xFFB71C1C),
      color: Color(0xFFB71C1C),
      airlineCode: 'AI',
    ),
    _FlightItem(
      airline: 'SpiceJet',
      flightNo: 'SG 404',
      from: 'DEL',
      to: 'BOM',
      dep: '11:20',
      arr: '13:45',
      duration: '2h 25m',
      stops: 0,
      price: 3199,
      tag: 'Best Value',
      tagColor: Color(0xFFE65100),
      color: Color(0xFFE65100),
      airlineCode: 'SG',
    ),
    _FlightItem(
      airline: 'Vistara',
      flightNo: 'UK 955',
      from: 'DEL',
      to: 'BOM',
      dep: '14:00',
      arr: '16:25',
      duration: '2h 25m',
      stops: 0,
      price: 6799,
      tag: 'Business',
      tagColor: Color(0xFF4A148C),
      color: Color(0xFF4A148C),
      airlineCode: 'UK',
    ),
    _FlightItem(
      airline: 'IndiGo',
      flightNo: '6E 542',
      from: 'DEL',
      to: 'BOM',
      dep: '16:45',
      arr: '20:10',
      duration: '3h 25m',
      stops: 1,
      price: 2799,
      tag: '1 Stop',
      tagColor: Color(0xFF6B7280),
      color: Color(0xFF1A237E),
      airlineCode: '6E',
    ),
    _FlightItem(
      airline: 'Air India',
      flightNo: 'AI 677',
      from: 'DEL',
      to: 'BOM',
      dep: '20:30',
      arr: '22:50',
      duration: '2h 20m',
      stops: 0,
      price: 4599,
      tag: 'Night Flight',
      tagColor: Color(0xFF1565C0),
      color: Color(0xFFB71C1C),
      airlineCode: 'AI',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
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
    final temp = _fromCtrl.text;
    _fromCtrl.text = _toCtrl.text;
    _toCtrl.text = temp;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero SliverAppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF0D47A1),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _FlightHero(
                    fromCtrl: _fromCtrl,
                    toCtrl: _toCtrl,
                    departure: _departure,
                    passengers: _passengers,
                    tripType: _tripType,
                    cabinClass: _cabinClass,
                    tripTypes: _tripTypes,
                    cabinClasses: _cabinClasses,
                    onTripTypeChanged: (v) => setState(() => _tripType = v),
                    onCabinChanged: (v) => setState(() => _cabinClass = v),
                    onPassengersChanged: (v) =>
                        setState(() => _passengers = v),
                    onDateTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _departure,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _departure = picked);
                      }
                    },
                    fmtDate: _fmtDate,
                    onSwap: _swapCities,
                  ),
                ),
                title: const Text(
                  'Flights',
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
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF0D47A1).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Color(0xFFFFD54F), size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lowest Fare, Guaranteed — Upto ₹4000 Off',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Book now & save more with GORUSHFLY',
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
                          'GORUSHFLY',
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Airline Filter ────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    itemCount: _airlineFilters.length,
                    itemBuilder: (context, i) {
                      final f = _airlineFilters[i];
                      final sel = _selectedAirline == f;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedAirline = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF0D47A1)
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
                        'Available Flights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_flights.length} flights found',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Flight Cards ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _FlightCard(
                      flight: _flights[index],
                      departure: _departure,
                      passengers: _passengers,
                      fmtDate: _fmtDate,
                    ),
                    childCount: _flights.length,
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
// Flight Hero Banner
// ─────────────────────────────────────────────────────────────────
class _FlightHero extends StatelessWidget {
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;
  final DateTime departure;
  final int passengers;
  final String tripType;
  final String cabinClass;
  final List<String> tripTypes;
  final List<String> cabinClasses;
  final ValueChanged<String> onTripTypeChanged;
  final ValueChanged<String> onCabinChanged;
  final ValueChanged<int> onPassengersChanged;
  final VoidCallback onDateTap;
  final String Function(DateTime) fmtDate;
  final VoidCallback onSwap;

  const _FlightHero({
    required this.fromCtrl,
    required this.toCtrl,
    required this.departure,
    required this.passengers,
    required this.tripType,
    required this.cabinClass,
    required this.tripTypes,
    required this.cabinClasses,
    required this.onTripTypeChanged,
    required this.onCabinChanged,
    required this.onPassengersChanged,
    required this.onDateTap,
    required this.fmtDate,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF0D47A1), Color(0xFF1565C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
          child: Column(
            children: [
              // Trip Type Tabs
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: tripTypes
                      .map(
                        (t) => Expanded(
                          child: GestureDetector(
                            onTap: () => onTripTypeChanged(t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: tripType == t
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: tripType == t
                                      ? const Color(0xFF0D47A1)
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),

              // From / To fields
              Row(
                children: [
                  Expanded(
                    child: _CityField(
                      controller: fromCtrl,
                      label: 'From',
                      icon: Icons.flight_takeoff_rounded,
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
                    child: _CityField(
                      controller: toCtrl,
                      label: 'To',
                      icon: Icons.flight_land_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date / Passengers / Cabin Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: onDateTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Departure',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(fmtDate(departure),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pax',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (passengers > 1) {
                                    onPassengersChanged(passengers - 1);
                                  }
                                },
                                child: const Icon(Icons.remove_rounded,
                                    color: Colors.white70, size: 14),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('$passengers',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    onPassengersChanged(passengers + 1),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.white70, size: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Class',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(cabinClass,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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

class _CityField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  const _CityField(
      {required this.controller, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 16),
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70, fontSize: 10),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Flight Data Model
// ─────────────────────────────────────────────────────────────────
class _FlightItem {
  final String airline;
  final String flightNo;
  final String from;
  final String to;
  final String dep;
  final String arr;
  final String duration;
  final int stops;
  final int price;
  final String tag;
  final Color tagColor;
  final Color color;
  final String airlineCode;

  const _FlightItem({
    required this.airline,
    required this.flightNo,
    required this.from,
    required this.to,
    required this.dep,
    required this.arr,
    required this.duration,
    required this.stops,
    required this.price,
    required this.tag,
    required this.tagColor,
    required this.color,
    required this.airlineCode,
  });
}

// ─────────────────────────────────────────────────────────────────
// Flight Card Widget
// ─────────────────────────────────────────────────────────────────
class _FlightCard extends StatelessWidget {
  final _FlightItem flight;
  final DateTime departure;
  final int passengers;
  final String Function(DateTime) fmtDate;

  const _FlightCard({
    required this.flight,
    required this.departure,
    required this.passengers,
    required this.fmtDate,
  });

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
                content: Text('Booking ${flight.flightNo}...'),
                backgroundColor: const Color(0xFF0D47A1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Airline info + Tag + Price
                Row(
                  children: [
                    // Airline Logo (colored circle)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: flight.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          flight.airlineCode,
                          style: TextStyle(
                            color: flight.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.airline,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          flight.flightNo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: flight.tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        flight.tag,
                        style: TextStyle(
                          color: flight.tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${flight.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'per person',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // Divider
                Container(
                  height: 1,
                  color: const Color(0xFFF3F4F6),
                ),
                const SizedBox(height: 14),

                // Flight path
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.dep,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          flight.from,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            flight.duration,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 4),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 1,
                                color: const Color(0xFFD1D5DB),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: flight.stops == 0
                                      ? const Color(0xFF00A651)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.stops == 0 ? 'Non-stop' : '${flight.stops} Stop',
                            style: TextStyle(
                              fontSize: 11,
                              color: flight.stops == 0
                                  ? const Color(0xFF00A651)
                                  : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.arr,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          flight.to,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                // Bottom: Date info + Book button
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 13, color: const Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      fmtDate(departure),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.person_outline_rounded,
                        size: 13, color: const Color(0xFF9CA3AF)),
                    const SizedBox(width: 3),
                    Text(
                      '$passengers pax',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
