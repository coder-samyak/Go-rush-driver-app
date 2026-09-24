import 'package:flutter/material.dart';
import '../core/theme.dart';

class OnboardingSlidesScreen extends StatefulWidget {
  final int initialPage;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final VoidCallback? onNextTap;
  final VoidCallback? onBackTap;

  const OnboardingSlidesScreen({
    super.key,
    this.initialPage = 0,
    this.onComplete,
    this.onSkip,
    this.onNextTap,
    this.onBackTap,
  });

  @override
  State<OnboardingSlidesScreen> createState() => _OnboardingSlidesScreenState();
}

class _OnboardingSlidesScreenState extends State<OnboardingSlidesScreen> {
  late PageController _pageController;
  late int _currentPage;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Drive Your Way',
      'subtitle': 'Flexible timings, better earnings and complete control over your daily schedule.',
      'icon': Icons.directions_car_filled_rounded,
      'accentColor': QuickServeColors.primaryBlue,
      'isAssetCar': true,
    },
    {
      'title': 'Get Ride Requests',
      'subtitle': 'Accept rides, navigate easily with turn-by-turn routes and reach your destination safely.',
      'icon': Icons.alt_route_rounded,
      'accentColor': QuickServeColors.statusGreen,
      'isAssetCar': false,
    },
    {
      'title': 'Earn More',
      'subtitle': 'With incentives, weekly bonuses and instant cash out directly to your bank account.',
      'icon': Icons.account_balance_wallet_rounded,
      'accentColor': Color(0xFFF59E0B),
      'isAssetCar': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, 2);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(covariant OnboardingSlidesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage) {
      _currentPage = widget.initialPage.clamp(0, 2);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < _slides.length - 1) {
      if (widget.onNextTap != null) {
        widget.onNextTap!();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
                onPressed: widget.onBackTap,
              )
            : null,
        actions: [
          if (_currentPage < _slides.length - 1)
            TextButton(
              onPressed: widget.onSkip ?? widget.onComplete,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Circle (Phones 21, 22, 23)
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: (slide['accentColor'] as Color).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: slide['isAssetCar'] == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/splash_car_front.jpg',
                                      width: 170,
                                      height: 170,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        slide['icon'] as IconData,
                                        size: 90,
                                        color: slide['accentColor'] as Color,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: (slide['accentColor'] as Color).withOpacity(0.16),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      slide['icon'] as IconData,
                                      size: 70,
                                      color: slide['accentColor'] as Color,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 38),

                        // Title
                        Text(
                          slide['title'] as String,
                          style: const TextStyle(
                            color: QuickServeColors.textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          slide['subtitle'] as String,
                          style: const TextStyle(
                            color: QuickServeColors.textSecondary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator [● ○ ○]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isCurrent = _currentPage == index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isCurrent ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCurrent ? QuickServeColors.primaryBlue : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Next / Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuickServeColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    shadowColor: QuickServeColors.primaryBlue.withOpacity(0.3),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
