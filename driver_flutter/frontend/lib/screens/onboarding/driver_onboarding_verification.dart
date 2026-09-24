import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/safe_avatar.dart';

class DriverOnboardingVerificationScreen extends StatefulWidget {
  final VoidCallback? onSubmit;

  const DriverOnboardingVerificationScreen({super.key, this.onSubmit});

  @override
  State<DriverOnboardingVerificationScreen> createState() => _DriverOnboardingVerificationScreenState();
}

class _DriverOnboardingVerificationScreenState extends State<DriverOnboardingVerificationScreen> {
  bool _declarationAccepted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRushColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Vehicle & Verification', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0x2200E676), borderRadius: BorderRadius.circular(6)),
            child: const Text('75% Done', style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Driver Header Card
              _buildDriverHeader(),
              const SizedBox(height: 16),
              // Required Documents Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Required Documents', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('4 of 5 Validated', style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              _buildDocItem(
                Icons.badge,
                'Driving License (Commercial)',
                'DL-0420180039291 • Valid till 2028',
                'DigiLocker Certified Match',
                isApproved: true,
                actionText: 'View Copy',
              ),
              const SizedBox(height: 10),
              _buildDocItem(
                Icons.directions_car,
                'Vehicle Registration Certificate (RC)',
                'Maruti Dzire Tour • DL 01 AB 9021',
                'CNG Commercial • Fitness: Nov 2028',
                isApproved: true,
              ),
              const SizedBox(height: 10),
              if (false) ...[
                _buildDocItem(
                Icons.assignment,
                'Commercial Insurance',
                'ICICI Lombard Policy • Exp: 14 Oct 2025',
                'Page 2 stamp signature partially blurry',
                isPending: true,
                reuploadButton: true,
              ),
              ],
              const SizedBox(height: 10),
              _buildDocItem(
                Icons.local_police,
                'Police Clearance Certificate',
                'Delhi State Police Verified #DCP-8812',
                'Clean Record Verified',
                isApproved: true,
              ),
              const SizedBox(height: 10),
              _buildSelfieCheckDoc(),
              const SizedBox(height: 18),
              // Payout & Settlement Setup
              _buildPayoutSetupCard(),
              const SizedBox(height: 14),
              // Checkbox Declaration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _declarationAccepted,
                    activeColor: GoRushColors.primaryGreen,
                    checkColor: Colors.black,
                    onChanged: (v) => setState(() => _declarationAccepted = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'I confirm that all uploaded vehicular certificates and license proofs are authentic. I agree to operate in full accordance with the Motor Vehicles Aggregator Guidelines (2020), state transport rules, and platform driver partner code of conduct.',
                      style: TextStyle(color: GoRushColors.textSecondary, fontSize: 10, height: 1.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onSubmit ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: GoRushColors.primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Submit Documents & Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.black),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GoRushColors.surfaceBorder),
      ),
      child: Row(
        children: [
          const SafeAvatar(
            size: 44,
            initials: 'RK',
            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Rajesh Kumar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: GoRushColors.primaryGreen, size: 14),
                  ],
                ),
                SizedBox(height: 2),
                Text('Fleet Partner ID: DL-99421', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
                Text('Cab Commercial (Sedan)', style: TextStyle(color: GoRushColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.shield, color: GoRushColors.primaryGreen, size: 22),
        ],
      ),
    );
  }

  Widget _buildDocItem(
    IconData icon,
    String title,
    String line1,
    String line2, {
    bool isApproved = false,
    bool isPending = false,
    String? actionText,
    bool reuploadButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isPending ? GoRushColors.orangeAccent.withOpacity(0.4) : GoRushColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: GoRushColors.primaryGreen, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              if (isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0x2200E676), borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: GoRushColors.primaryGreen, size: 10),
                      SizedBox(width: 2),
                      Text('Approved', style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0x22FB923C), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Pending Review', style: TextStyle(color: GoRushColors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(line1, style: const TextStyle(color: GoRushColors.textSecondary, fontSize: 11)),
          Text(line2, style: TextStyle(color: isPending ? GoRushColors.orangeAccent : GoRushColors.textMuted, fontSize: 10)),
          if (reuploadButton) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload, size: 14, color: Colors.white),
              label: const Text('Re-upload', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2E48),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              onPressed: () {},
            ),
          ],
          if (actionText != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(actionText, style: const TextStyle(color: GoRushColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelfieCheckDoc() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GoRushColors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.face, color: GoRushColors.blueAccent, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Daily Face / Liveness', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0x2238BDF8), borderRadius: BorderRadius.circular(4)),
                child: const Text('Required Today', style: TextStyle(color: GoRushColors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Liveness check required before shift activation', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            label: const Text('Capture Live Selfie Now', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF18324E),
              minimumSize: const Size(double.infinity, 36),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutSetupCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GoRushColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoRushColors.surfaceBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payout & Settlement Setup', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Instant Daily Payouts Enabled', style: TextStyle(color: GoRushColors.primaryGreen, fontSize: 9)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.account_balance, color: GoRushColors.primaryGreen, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HDFC Bank Savings A/C', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('•••• •••• 4892 (IFSC: HDFC0000240)', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: GoRushColors.primaryGreen, size: 16),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.qr_code, color: GoRushColors.primaryGreen, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Virtual Payment Address (UPI)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('rajesh.kumar@okhdfcbank', style: TextStyle(color: GoRushColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              Icon(Icons.check_circle, color: GoRushColors.primaryGreen, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
