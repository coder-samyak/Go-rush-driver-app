import 'package:flutter/material.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/tokens.dart';

/// Premium Metro transport option card for the GoRush Customer App.
///
/// Renders using the existing GoRush design language but visually
/// communicates "Coming Soon" — no booking API is called.
class GoRushMetroCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const GoRushMetroCard({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _metroBlue = Color(0xFF1565C0);
  static const Color _metroBlueLightBg = Color(0xFFEFF6FF);
  static const Color _metroBlueBorder = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Metro ride option — Coming Soon',
      button: true,
      child: AnimatedContainer(
        duration: GoRushMotion.normal,
        decoration: BoxDecoration(
          color: isSelected ? _metroBlueLightBg : GoRushColors.surface,
          border: Border.all(
            color: isSelected ? _metroBlueBorder : GoRushColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _metroBlue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GoRushRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(GoRushSpacing.md),
            child: Row(
              children: [
                // Metro Icon Badge
                AnimatedContainer(
                  duration: GoRushMotion.normal,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : _metroBlueLightBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.subway_rounded,
                    color: isSelected ? Colors.white : _metroBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: GoRushSpacing.md),

                // Title + Description + Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Metro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: GoRushColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // "Coming Soon" badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _metroBlueLightBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _metroBlueBorder.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'Coming Soon',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _metroBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Fast • Affordable • Direct city transit',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.rocket_launch_rounded,
                            size: 12,
                            color: _metroBlue.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Launching soon in GoRush',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _metroBlue.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Fare / Availability Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isSelected ? _metroBlue : GoRushColors.textSecondary,
                      size: 20,
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
