import 'package:flutter/material.dart';

class FixtureSkeletonList extends StatelessWidget {
  final int itemCount;
  final Color accentColor;

  const FixtureSkeletonList({
    super.key,
    this.itemCount = 4,
    this.accentColor = Colors.greenAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return _SkeletonCard(accentColor: accentColor);
      }),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Color accentColor;

  const _SkeletonCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff161b22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _block(width: 34, height: 34, radius: 12),
              const SizedBox(width: 12),
              Expanded(child: _block(height: 14, radius: 8)),
              const SizedBox(width: 12),
              _block(width: 54, height: 22, radius: 999, color: accentColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _teamPlaceholder()),
              const SizedBox(width: 12),
              _block(width: 44, height: 18, radius: 8),
              const SizedBox(width: 12),
              Expanded(child: _teamPlaceholder(alignEnd: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamPlaceholder({bool alignEnd = false}) {
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!alignEnd) ...[
          _block(width: 28, height: 28, radius: 999),
          const SizedBox(width: 8),
        ],
        Flexible(child: _block(height: 13, radius: 8)),
        if (alignEnd) ...[
          const SizedBox(width: 8),
          _block(width: 28, height: 28, radius: 999),
        ],
      ],
    );
  }

  Widget _block({
    double? width,
    required double height,
    required double radius,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(
          alpha: color == null ? 0.08 : 0.16,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
