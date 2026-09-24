import 'package:flutter/material.dart';
import '../core/theme.dart';

class FloatingSosButton extends StatefulWidget {
  final VoidCallback onTap;
  final double bottomOffset;
  final double rightOffset;

  const FloatingSosButton({
    super.key,
    required this.onTap,
    this.bottomOffset = 80,
    this.rightOffset = 16,
  });

  @override
  State<FloatingSosButton> createState() => _FloatingSosButtonState();
}

class _FloatingSosButtonState extends State<FloatingSosButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomOffset,
      right: widget.rightOffset,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final scale = 1.0 + (_animController.value * 0.08);
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GoRushColors.sosRed,
                  boxShadow: [
                    BoxShadow(
                      color: GoRushColors.sosRed.withOpacity(0.45 + (_animController.value * 0.3)),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
