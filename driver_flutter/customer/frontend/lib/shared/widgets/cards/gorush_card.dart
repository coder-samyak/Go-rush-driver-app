import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';

class GoRushCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GoRushCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GoRushSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GoRushColors.surface,
        borderRadius: BorderRadius.circular(GoRushRadius.md),
        boxShadow: const [
          BoxShadow(
            color: GoRushColors.border,
            offset: Offset(0, 1),
            blurRadius: 4,
          )
        ],
      ),
      child: child,
    );
  }
}
