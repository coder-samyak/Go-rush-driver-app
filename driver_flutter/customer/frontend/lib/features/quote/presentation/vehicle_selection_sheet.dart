import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/pricing/domain/quote_models.dart';
import '../../../core/pricing/domain/ride_category.dart';
import '../../../core/pricing/data/quote_repository.dart';
import '../../../core/ride/data/ride_repository.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';
import 'fare_breakdown_sheet.dart';
import 'ride_booking_confirmation_screen.dart';

class VehicleSelectionSheet extends StatefulWidget {
  final QuoteRepository quoteRepository;
  final RideRepository rideRepository;
  final VoidCallback onConfirm;

  const VehicleSelectionSheet({
    super.key,
    required this.quoteRepository,
    required this.rideRepository,
    required this.onConfirm,
  });

  @override
  State<VehicleSelectionSheet> createState() => _VehicleSelectionSheetState();
}

class _VehicleSelectionSheetState extends State<VehicleSelectionSheet> {
  bool _isLoading = true;
  final bool _isCreatingRide = false;
  bool _isApplyingPromo = false;
  String? _error;
  List<Quote> _quotes = [];
  Quote? _selectedQuote;
  Timer? _expiryTimer;
  bool _isExpired = false;

  String _selectedFilter = 'All';
  String _paymentMethod = 'Google Pay';
  final TextEditingController _promoController = TextEditingController();
  String? _activePromo;
  String? _promoMessage;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isExpired = false;
    });

    try {
      final quotes = await widget.quoteRepository.generateQuotes(
        distanceMeters: 5500, // 5.5 km
        durationSeconds: 900,  // 15 mins
        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (mounted) {
        setState(() {
          _quotes = quotes;
          if (quotes.isNotEmpty) {
            _selectedQuote = quotes.first;
          }
          _isLoading = false;
        });
        _startExpiryTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    if (_quotes.isEmpty) return;

    final expiresAt = _quotes.first.expiresAt;
    final timeToExpiry = expiresAt.difference(DateTime.now());

    if (timeToExpiry.isNegative) {
      setState(() => _isExpired = true);
    } else {
      _expiryTimer = Timer(timeToExpiry, () {
        if (mounted) {
          setState(() => _isExpired = true);
        }
      });
    }
  }

  Future<void> _applyPromoCode([String? codeToApply]) async {
    final code = codeToApply ?? _promoController.text.trim();
    if (code.isEmpty || _selectedQuote == null) return;

    setState(() {
      _isApplyingPromo = true;
      _promoMessage = null;
    });

    try {
      final updatedQuote = await widget.quoteRepository.applyPromo(_selectedQuote!.quoteId, code);
      if (mounted) {
        setState(() {
          _selectedQuote = updatedQuote;
          _activePromo = code.toUpperCase();
          _promoMessage = '🎉 Coupon ${code.toUpperCase()} Applied!';
          _isApplyingPromo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _promoMessage = 'Invalid Promo Code. Try GORUSH50';
          _isApplyingPromo = false;
        });
      }
    }
  }

  void _showFareBreakdown(Quote quote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FareBreakdownSheet(quote: quote),
    );
  }

  void _confirmRide() {
    if (_selectedQuote == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideBookingConfirmationScreen(
          quote: _selectedQuote!,
          rideRepository: widget.rideRepository,
          pickupAddress: 'Sector 63, Noida (GPS Fixed)',
          dropoffAddress: 'Terminal 3, IGI Airport, New Delhi',
          paymentMethod: _paymentMethod,
        ),
      ),
    );
  }

  List<Quote> get _filteredQuotes {
    if (_selectedFilter == 'Bike') {
      return _quotes.where((q) => q.rideCategory.code == RideCategoryType.bike || q.rideCategory.code == RideCategoryType.bikeLite).toList();
    } else if (_selectedFilter == 'Auto') {
      return _quotes.where((q) => q.rideCategory.code == RideCategoryType.auto || q.rideCategory.code == RideCategoryType.autoLite).toList();
    } else if (_selectedFilter == 'Cab') {
      return _quotes.where((q) => q.rideCategory.code == RideCategoryType.cab || q.rideCategory.code == RideCategoryType.cabLite).toList();
    } else if (_selectedFilter == 'Sedan & SUV') {
      return _quotes.where((q) => q.rideCategory.code == RideCategoryType.primeSedan || q.rideCategory.code == RideCategoryType.sevenSeater).toList();
    }
    return _quotes;
  }

  IconData _getCategoryIcon(RideCategoryType code) {
    switch (code) {
      case RideCategoryType.bike:
      case RideCategoryType.bikeLite:
        return Icons.two_wheeler_rounded;
      case RideCategoryType.auto:
      case RideCategoryType.autoLite:
        return Icons.electric_rickshaw_rounded;
      case RideCategoryType.cab:
      case RideCategoryType.cabLite:
        return Icons.directions_car_filled_rounded;
      case RideCategoryType.primeSedan:
        return Icons.local_taxi_rounded;
      case RideCategoryType.sevenSeater:
        return Icons.airport_shuttle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: const BoxDecoration(
          color: GoRushColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: GoRushSpacing.md),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Handle Drag Line
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title & Route Info Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Choose Vehicle & Fare', style: GoRushTypography.h3.copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text('📍 Sector 63 ➔ 🏁 Terminal 3 (5.5 km)', style: GoRushTypography.caption.copyWith(color: GoRushColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GoRushColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified_rounded, color: GoRushColors.primary, size: 14),
                          SizedBox(width: 4),
                          Text('Guaranteed Fare', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GoRushColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter Category Chips (All, Daily, Comfort, Premium XL)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md),
                child: Row(
                  children: ['All', 'Bike', 'Auto', 'Cab', 'Sedan & SUV'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(filter, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selectedColor: GoRushColors.primaryLight,
                        checkmarkColor: GoRushColors.primary,
                        labelStyle: TextStyle(color: isSelected ? GoRushColors.primary : GoRushColors.textPrimary),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? GoRushColors.primary : Colors.transparent),
                        ),
                        onSelected: (val) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Quotes List
              if (_isLoading)
                const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator(color: GoRushColors.primary)),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(GoRushSpacing.md),
                  child: Text(_error!, style: GoRushTypography.body1.copyWith(color: GoRushColors.error)),
                )
              else
                ..._filteredQuotes.map((quote) => _buildVehicleCard(quote)),

              if (_isExpired)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: GoRushSpacing.xs),
                  child: Text(
                    '⚠️ Fare estimates expired. Tap below to refresh.',
                    style: GoRushTypography.body2.copyWith(color: GoRushColors.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 12),

              // Voucher & Promo Code Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer_rounded, size: 16, color: GoRushColors.primary),
                            const SizedBox(width: 6),
                            Text('Apply Promo Code', style: GoRushTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GoRushColors.textPrimary)),
                          ],
                        ),
                        if (_activePromo != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: GoRushColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                            child: Text('ACTIVE: $_activePromo', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GoRushColors.primary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Enter code e.g. GORUSH50',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GoRushColors.primary)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isApplyingPromo ? null : () => _applyPromoCode(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GoRushColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isApplyingPromo
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                    if (_promoMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(_promoMessage!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _promoMessage!.contains('🎉') ? GoRushColors.primary : Colors.red)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payment Method Switcher Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _paymentMethod == 'Google Pay'
                                ? Icons.account_balance_wallet_rounded
                                : _paymentMethod == 'GoRush Wallet'
                                    ? Icons.credit_card_rounded
                                    : Icons.payments_rounded,
                            size: 18,
                            color: GoRushColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _paymentMethod == 'GoRush Wallet' ? 'GoRush Wallet (₹450)' : _paymentMethod,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_paymentMethod == 'Google Pay') {
                              _paymentMethod = 'GoRush Wallet';
                            } else if (_paymentMethod == 'GoRush Wallet') {
                              _paymentMethod = 'Cash';
                            } else {
                              _paymentMethod = 'Google Pay';
                            }
                          });
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                        child: const Text('Change', style: TextStyle(fontSize: 12, color: GoRushColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Confirm Booking CTA Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: _isExpired
                          ? [Colors.grey[400]!, Colors.grey[500]!]
                          : [const Color(0xFF00C853), const Color(0xFF00A843)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: (_isExpired || _isCreatingRide) ? (_isExpired ? _loadQuotes : null) : _confirmRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isCreatingRide
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isExpired
                                    ? 'Refresh Fare Estimates'
                                    : 'Confirm ${_selectedQuote?.rideCategory.displayName ?? "Ride"} • ${_selectedQuote?.fareBreakdown.total.formatted ?? ""}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Quote quote) {
    final isSelected = _selectedQuote?.quoteId == quote.quoteId;
    final cat = quote.rideCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: 4),
      child: GestureDetector(
        onTap: () {
          if (!_isExpired && !_isCreatingRide) {
            setState(() => _selectedQuote = quote);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? GoRushColors.primaryLight.withValues(alpha: 0.6) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? GoRushColors.primary : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: GoRushColors.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                : const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Vehicle Icon Badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? GoRushColors.primary : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(cat.code),
                  color: isSelected ? Colors.white : GoRushColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Subtitle, Capacity & ETA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cat.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: GoRushColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 11, color: GoRushColors.textSecondary),
                              const SizedBox(width: 2),
                              Text('${cat.capacity}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GoRushColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat.description,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: GoRushColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${cat.etaMinutes} mins away',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GoRushColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Fare Estimate & Breakdown Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quote.fareBreakdown.total.formatted,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? GoRushColors.primary : GoRushColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () => _showFareBreakdown(quote),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Details', style: TextStyle(fontSize: 10, color: GoRushColors.primary, fontWeight: FontWeight.bold)),
                        SizedBox(width: 2),
                        Icon(Icons.info_outline_rounded, size: 13, color: GoRushColors.primary),
                      ],
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
