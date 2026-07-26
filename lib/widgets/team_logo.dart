import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TeamLogo extends StatelessWidget {
  final String logoUrl;
  final double size;
  final Color fallbackColor;
  final bool whiteBackground;

  const TeamLogo({
    super.key,
    required this.logoUrl,
    required this.size,
    this.fallbackColor = Colors.greenAccent,
    this.whiteBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: whiteBackground
            ? Colors.white
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: logoUrl.trim().isEmpty
          ? _fallback()
          : CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => _fallback(alpha: 0.45),
              errorWidget: (_, __, ___) => _fallback(),
            ),
    );
  }

  Widget _fallback({double alpha = 1}) {
    return Icon(
      Icons.shield_rounded,
      color: fallbackColor.withValues(alpha: alpha),
      size: size * 0.72,
    );
  }
}
