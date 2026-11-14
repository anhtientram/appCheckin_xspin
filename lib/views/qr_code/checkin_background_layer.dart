import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:checkin/base/app_responsive.dart';
import 'package:flutter/material.dart';

class CheckinBackgroundLayer extends StatelessWidget {
  const CheckinBackgroundLayer({
    super.key,
    required this.imageQr,
    required this.cutoutRect,
  });

  final String? imageQr;
  final Rect cutoutRect;

  @override
  Widget build(BuildContext context) {
    final backgroundImage = _buildImageProvider();
    final hasBackgroundImage = backgroundImage != null;
    final foregroundFit =
        context.responsive.isTablet ? BoxFit.fill : BoxFit.contain;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBackgroundImage)
            ClipPath(
              clipper: _InvertedCutoutClipper(cutoutRect),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: backgroundImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.16),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: backgroundImage,
                        // Fill the complete preview on wide screens such as
                        // iPad without cropping its content. Phones retain the
                        // complete image composition at its original ratio.
                        fit: foregroundFit,
                        alignment: Alignment.center,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ],
              ),
            ),
          if (!hasBackgroundImage)
            ClipPath(
              clipper: _InvertedCutoutClipper(cutoutRect),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),
            ),
          CustomPaint(
            painter: _ScannerOverlayPainter(
              cutoutRect,
              overlayColor: !hasBackgroundImage
                  ? Colors.black.withValues(alpha: 0.42)
                  : Colors.black.withValues(alpha: 0.18),
            ),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _buildImageProvider() {
    final rawImage = imageQr?.trim() ?? '';
    if (rawImage.isEmpty) {
      return null;
    }

    if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
      return NetworkImage(rawImage);
    }

    final bytes = _tryDecodeImage(rawImage);
    if (bytes != null) {
      return MemoryImage(bytes);
    }

    return null;
  }

  Uint8List? _tryDecodeImage(String rawImage) {
    try {
      final commaIndex = rawImage.indexOf(',');
      final base64Value = rawImage.startsWith('data:image')
          ? rawImage.substring(commaIndex + 1)
          : rawImage;
      return base64Decode(base64Value);
    } catch (_) {
      return null;
    }
  }
}

class _InvertedCutoutClipper extends CustomClipper<Path> {
  const _InvertedCutoutClipper(this.cutoutRect);

  final Rect cutoutRect;

  @override
  Path getClip(Size size) {
    final fullRect = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          const Radius.circular(28),
        ),
      );

    return Path.combine(
      PathOperation.difference,
      fullRect,
      cutoutPath,
    );
  }

  @override
  bool shouldReclip(covariant _InvertedCutoutClipper oldClipper) {
    return oldClipper.cutoutRect != cutoutRect;
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter(
    this.cutoutRect, {
    required this.overlayColor,
  });

  final Rect cutoutRect;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = overlayColor;
    final fullRect = Offset.zero & size;
    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(28),
    );

    final fullPath = Path()..addRect(fullRect);
    final cutoutPath = Path()..addRRect(cutoutRRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutoutRect != cutoutRect ||
        oldDelegate.overlayColor != overlayColor;
  }
}
