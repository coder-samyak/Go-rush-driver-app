import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TermsConditionsScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onBackTap;

  const TermsConditionsScreen({
    super.key,
    this.onComplete,
    this.onBackTap,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _agree1 = true;
  bool _agree2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: QuickServeColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: QuickServeColors.borderLight),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: QuickServeColors.borderLight),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GoRush Fleet Partner Agreement',
                          style: TextStyle(color: QuickServeColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Service Standards: You agree to provide safe, respectful, and reliable transportation services in compliance with local motor vehicle regulations.\n\n'
                          '2. Fare Calculation: GoRush calculates fares using transparent GPS distance and time algorithms. Commissions and taxes will be itemized on each receipt.\n\n'
                          '3. Safety Protocol: Drivers must maintain valid insurance, PUC, and comply with zero-tolerance alcohol and drug policies.\n\n'
                          '4. Cancellation & Ratings: Frequent unverified cancellations may impact driver tier and peak incentive eligibility.',
                          style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: QuickServeColors.primaryOrange,
                value: _agree1,
                onChanged: (val) => setState(() => _agree1 = val ?? false),
                title: const Text(
                  'I accept the GoRush Driver Partner Agreement and fare structure.',
                  style: TextStyle(color: QuickServeColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: QuickServeColors.primaryOrange,
                value: _agree2,
                onChanged: (val) => setState(() => _agree2 = val ?? false),
                title: const Text(
                  'I agree to follow Passenger Safety & Zero-Tolerance Guidelines.',
                  style: TextStyle(color: QuickServeColors.textDark, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: (_agree1 && _agree2) ? widget.onComplete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
