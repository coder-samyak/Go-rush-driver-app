import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// Train Screen
// ─────────────────────────────────────────────────────────────────
class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _fromCtrl =
      TextEditingController(text: 'New Delhi (NDLS)');
  final TextEditingController _toCtrl =
      TextEditingController(text: 'Mumbai Central (MMCT)');
  DateTime _journeyDate = DateTime.now().add(const Duration(days: 5));
  String _selectedClass = 'All Classes';
  String _selectedQuota = 'General';

  final List<String> _classes = [
    'All Classes', '1A', '2A', '3A', 'SL', '2S', 'CC',
  ];

  final List<String> _quotas = ['General', 'Ladies', 'Senior Citizen', 'Tatkal'];

  static const List<_TrainItem> _trains = [
    _TrainItem(
      name: 'Rajdhani Express',
      number: '12951',
      from: 'NDLS',
      to: 'MMCT',
      dep: '16:55',
      arr: '08:35+1',
      duration: '15h 40m',
      days: 'Mon, Wed, Thu, Sat',
      classes: [
        _TrainClass(code: '1A', price: 4785, available: 12),
        _TrainClass(code: '2A', price: 2800, available: 43),
        _TrainClass(code: '3A', price: 1985, available: 106),
      ],
      tag: 'Zero Service Fee',
      tagColor: Color(0xFF5E35B1),
      color: Color(0xFF5E35B1),
      type: 'Superfast',
    ),
    _TrainItem(
      name: 'Mumbai Mail',
      number: '12137',
      from: 'NDLS',
      to: 'MMCT',
      dep: '23:25',
      arr: '21:45+1',
      duration: '22h 20m',
      days: 'Daily',
      classes: [
        _TrainClass(code: '2A', price: 2430, available: 28),
        _TrainClass(code: '3A', price: 1700, available: 84),
        _TrainClass(code: 'SL', price: 580, available: 312),
      ],
      tag: 'Daily Train',
      tagColor: Color(0xFF0288D1),
      color: Color(0xFF0288D1),
      type: 'Mail/Express',
    ),
    _TrainItem(
      name: 'Shatabdi Express',
      number: '12009',
      from: 'NDLS',
      to: 'MMCT',
      dep: '06:00',
      arr: '22:15',
      duration: '16h 15m',
      days: 'Tue, Wed, Fri, Sun',
      classes: [
        _TrainClass(code: 'CC', price: 1990, available: 65),
        _TrainClass(code: '2S', price: 685, available: 142),
      ],
      tag: 'Premium',
      tagColor: Color(0xFFE65100),
      color: Color(0xFFE65100),
      type: 'Shatabdi',
    ),
    _TrainItem(
      name: 'Duronto Express',
      number: '12223',
      from: 'NDLS',
      to: 'MMCT',
      dep: '22:50',
      arr: '15:15+1',
      duration: '16h 25m',
      days: 'Mon, Fri',
      classes: [
        _TrainClass(code: '1A', price: 5200, available: 8),
        _TrainClass(code: '2A', price: 3050, available: 22),
        _TrainClass(code: '3A', price: 2150, available: 78),
      ],
      tag: 'Non-stop',
      tagColor: Color(0xFF1B5E20),
      color: Color(0xFF2E7D32),
      type: 'Duronto',
    ),
    _TrainItem(
      name: 'Garib Rath Express',
      number: '12909',
      from: 'NDLS',
      to: 'MMCT',
      dep: '15:40',
      arr: '11:05+1',
      duration: '19h 25m',
      days: 'Mon, Thu',
      classes: [
        _TrainClass(code: '3A', price: 945, available: 198),
        _TrainClass(code: 'SL', price: 340, available: 486),
      ],
      tag: 'Budget',
      tagColor: Color(0xFF374151),
      color: Color(0xFF374151),
      type: 'Garib Rath',
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

  void _swapStations() {
    final t = _fromCtrl.text;
    _fromCtrl.text = _toCtrl.text;
    _toCtrl.text = t;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero SliverAppBar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(0xFF4A148C),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _TrainHero(
                    fromCtrl: _fromCtrl,
                    toCtrl: _toCtrl,
                    journeyDate: _journeyDate,
                    selectedClass: _selectedClass,
                    selectedQuota: _selectedQuota,
                    classes: _classes,
                    quotas: _quotas,
                    onClassChanged: (v) => setState(() => _selectedClass = v),
                    onQuotaChanged: (v) => setState(() => _selectedQuota = v),
                    onDateTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _journeyDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 120)),
                      );
                      if (picked != null) setState(() => _journeyDate = picked);
                    },
                    fmtDate: _fmtDate,
                    onSwap: _swapStations,
                  ),
                ),
                title: const Text(
                  'Train Tickets',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),

              // ── Zero Service Fee Banner ───────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A148C).withValues(alpha: 0.35),
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
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Zero Service Fee — Book trains for FREE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Powered by Confirmtkt — No hidden charges',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white54, size: 14),
                    ],
                  ),
                ),
              ),

              // ── Class Chips ───────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    itemCount: _classes.length,
                    itemBuilder: (context, i) {
                      final f = _classes[i];
                      final sel = _selectedClass == f;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedClass = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF4A148C)
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
                        'Available Trains',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_trains.length} trains',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Train Cards ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _TrainCard(train: _trains[index], fmtDate: _fmtDate, date: _journeyDate),
                    childCount: _trains.length,
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
// Train Hero Banner
// ─────────────────────────────────────────────────────────────────
class _TrainHero extends StatelessWidget {
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;
  final DateTime journeyDate;
  final String selectedClass;
  final String selectedQuota;
  final List<String> classes;
  final List<String> quotas;
  final ValueChanged<String> onClassChanged;
  final ValueChanged<String> onQuotaChanged;
  final VoidCallback onDateTap;
  final String Function(DateTime) fmtDate;
  final VoidCallback onSwap;

  const _TrainHero({
    required this.fromCtrl,
    required this.toCtrl,
    required this.journeyDate,
    required this.selectedClass,
    required this.selectedQuota,
    required this.classes,
    required this.quotas,
    required this.onClassChanged,
    required this.onQuotaChanged,
    required this.onDateTap,
    required this.fmtDate,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0030), Color(0xFF4A148C), Color(0xFF6A1B9A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
          child: Column(
            children: [
              // From / To row with station codes
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: fromCtrl,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                              Icons.trip_origin_rounded,
                              color: Color(0xFF00E5FF),
                              size: 18),
                          labelText: 'From Station',
                          labelStyle: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                          border: InputBorder.none,
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
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
                      child: const Icon(Icons.swap_vert_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: TextField(
                        controller: toCtrl,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFFF80AB),
                              size: 18),
                          labelText: 'To Station',
                          labelStyle: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                          border: InputBorder.none,
                          floatingLabelBehavior:
                              FloatingLabelBehavior.always,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date + Class + Quota row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: onDateTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: Colors.white70, size: 15),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 9)),
                                Text(fmtDate(journeyDate),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedClass,
                          dropdownColor: const Color(0xFF4A148C),
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                          items: classes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              v != null ? onClassChanged(v) : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedQuota,
                          dropdownColor: const Color(0xFF4A148C),
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                          items: quotas
                              .map(
                                (q) => DropdownMenuItem(
                                  value: q,
                                  child: Text(q,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              v != null ? onQuotaChanged(v) : null,
                        ),
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

// ─────────────────────────────────────────────────────────────────
// Train Data Models
// ─────────────────────────────────────────────────────────────────
class _TrainClass {
  final String code;
  final int price;
  final int available;
  const _TrainClass(
      {required this.code, required this.price, required this.available});
}

class _TrainItem {
  final String name;
  final String number;
  final String from;
  final String to;
  final String dep;
  final String arr;
  final String duration;
  final String days;
  final List<_TrainClass> classes;
  final String tag;
  final Color tagColor;
  final Color color;
  final String type;

  const _TrainItem({
    required this.name,
    required this.number,
    required this.from,
    required this.to,
    required this.dep,
    required this.arr,
    required this.duration,
    required this.days,
    required this.classes,
    required this.tag,
    required this.tagColor,
    required this.color,
    required this.type,
  });
}

// ─────────────────────────────────────────────────────────────────
// Train Card Widget
// ─────────────────────────────────────────────────────────────────
class _TrainCard extends StatelessWidget {
  final _TrainItem train;
  final String Function(DateTime) fmtDate;
  final DateTime date;

  const _TrainCard(
      {required this.train, required this.fmtDate, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                content: Text('Checking availability for ${train.name}...'),
                backgroundColor: const Color(0xFF4A148C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Top colored header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      train.color,
                      train.color.withValues(alpha: 0.75)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.train_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            train.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '#${train.number}  ·  ${train.type}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        train.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Route
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              train.dep,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              train.from,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151)),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                train.duration,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: train.color,
                                    ),
                                  ),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (ctx, constraints) {
                                        final dotCount =
                                            (constraints.maxWidth / 8)
                                                .floor();
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(
                                            dotCount,
                                            (i) => Container(
                                              width: 3,
                                              height: 3,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: train.color.withValues(
                                                    alpha: i % 2 == 0
                                                        ? 0.5
                                                        : 0.2),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: train.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fmtDate(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              train.arr,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              train.to,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    // Runs on days
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          'Runs: ${train.days}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    // Class availability table
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9D8FF)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Class',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Fare',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  flex: 3,
                                  child: Text('Availability',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  flex: 2,
                                  child: Text('Book',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w600))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...train.classes.map((cls) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: train.color
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          cls.code,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: train.color,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '₹${cls.price}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: cls.available > 10
                                                ? const Color(0xFFDCFCE7)
                                                : const Color(0xFFFEE2E2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${cls.available} avail.',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: cls.available > 10
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFF991B1B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 5),
                                            decoration: BoxDecoration(
                                              color: train.color,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Book',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
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
