import 'package:flutter/material.dart';
import '../theme/gorush_colors.dart';

class GoRushCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool showBorder;

  const GoRushCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: GoRushColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: showBorder ? Border.all(color: GoRushColors.divider) : null,
          boxShadow: showBorder 
              ? null 
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: child,
      ),
    );
  }
}
