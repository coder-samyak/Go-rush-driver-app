import 'package:flutter/material.dart';
import '../core/theme.dart';

class SafeAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String initials;
  final Color borderColor;
  final double borderWidth;
  final IconData fallbackIcon;

  const SafeAvatar({
    super.key,
    this.imageUrl,
    double size = 40,
    double? radius,
    String initials = 'RS',
    String? fallbackText,
    this.borderColor = QuickServeColors.primaryOrange,
    this.borderWidth = 1.5,
    this.fallbackIcon = Icons.person,
  })  : size = radius != null ? radius * 2 : size,
        initials = fallbackText ?? initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback();
                },
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                fallbackIcon,
                size: size * 0.55,
                color: QuickServeColors.textSecondary,
              ),
      ),
    );
  }
}
