import 'package:flutter/material.dart';

class ScanGuideFrame extends StatelessWidget {
  const ScanGuideFrame({
    super.key,
    required this.size,
    required this.accentColor,
  });

  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Stack(
          children: [
            _FrameCorner(
              alignment: Alignment.topLeft,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.topRight,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.bottomLeft,
              accentColor: accentColor,
            ),
            _FrameCorner(
              alignment: Alignment.bottomRight,
              accentColor: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  const _FrameCorner({
    required this.alignment,
    required this.accentColor,
  });

  final Alignment alignment;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: accentColor, width: 5)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isLeft && isTop ? 28 : 0),
            topRight: Radius.circular(!isLeft && isTop ? 28 : 0),
            bottomLeft: Radius.circular(isLeft && !isTop ? 28 : 0),
            bottomRight: Radius.circular(!isLeft && !isTop ? 28 : 0),
          ),
        ),
      ),
    );
  }
}
