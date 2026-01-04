import 'package:flutter/material.dart';

// ============================================
// lib/presentation/widgets/camera/face_filter_overlay.dart
// AR Face Filters (Mock Implementation)
// ============================================

class FaceFilterOverlay extends StatefulWidget {
  final String? filter;

  const FaceFilterOverlay({super.key, this.filter});

  @override
  State<FaceFilterOverlay> createState() => _FaceFilterOverlayState();
}

class _FaceFilterOverlayState extends State<FaceFilterOverlay> {
  // Mock face detection - in a real app, this would use ML Kit
  List<Rect>? _faceRects;

  @override
  void initState() {
    super.initState();
    // Mock face detection - simulate finding a face in the center
    if (widget.filter != null) {
      _faceRects = [
         Rect.fromCenter(
          center: Offset(0.5, 0.4), // Center of screen
          width: 0.3,
          height: 0.4,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter == null || _faceRects == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: FaceFilterPainter(
            faceRects: _faceRects!,
            filter: widget.filter!,
            canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}

class FaceFilterPainter extends CustomPainter {
  final List<Rect> faceRects;
  final String filter;
  final Size canvasSize;

  FaceFilterPainter({
    required this.faceRects,
    required this.filter,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final faceRect in faceRects) {
      // Convert normalized coordinates to actual canvas coordinates
      final actualRect = Rect.fromLTRB(
        faceRect.left * canvasSize.width,
        faceRect.top * canvasSize.height,
        faceRect.right * canvasSize.width,
        faceRect.bottom * canvasSize.height,
      );

      // Apply filter overlay based on filter type
      _applyFilterOverlay(canvas, actualRect, filter);
    }
  }

  void _applyFilterOverlay(Canvas canvas, Rect faceRect, String filter) {
    switch (filter) {
      case 'Glasses':
        _drawGlasses(canvas, faceRect);
        break;
      case 'Hat':
        _drawHat(canvas, faceRect);
        break;
      case 'Mustache':
        _drawMustache(canvas, faceRect);
        break;
      case 'Crown':
        _drawCrown(canvas, faceRect);
        break;
      default:
        // No overlay
        break;
    }
  }

  void _drawGlasses(Canvas canvas, Rect faceRect) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.black;

    final centerX = faceRect.center.dx;
    final centerY = faceRect.center.dy;
    final width = faceRect.width * 0.6;
    final height = faceRect.height * 0.3;

    // Left lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - width * 0.3, centerY),
        width: width * 0.35,
        height: height,
      ),
      paint,
    );

    // Right lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + width * 0.3, centerY),
        width: width * 0.35,
        height: height,
      ),
      paint,
    );

    // Bridge
    canvas.drawLine(
      Offset(centerX - width * 0.175, centerY),
      Offset(centerX + width * 0.175, centerY),
      paint,
    );
  }

  void _drawHat(Canvas canvas, Rect faceRect) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    final centerX = faceRect.center.dx;
    final topY = faceRect.top - faceRect.height * 0.2;
    final width = faceRect.width * 0.8;
    final height = faceRect.height * 0.4;

    // Hat brim
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, faceRect.top),
        width: width,
        height: height * 0.5,
      ),
      paint,
    );

    // Hat crown
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, topY),
        width: width * 0.6,
        height: height,
      ),
      paint,
    );
  }

  void _drawMustache(Canvas canvas, Rect faceRect) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    final centerX = faceRect.center.dx;
    final centerY = faceRect.center.dy + faceRect.height * 0.15;
    final width = faceRect.width * 0.4;
    final height = faceRect.height * 0.1;

    // Left curl
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - width * 0.3, centerY),
        width: width * 0.4,
        height: height,
      ),
      paint,
    );

    // Right curl
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + width * 0.3, centerY),
        width: width * 0.4,
        height: height,
      ),
      paint,
    );

    // Center
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + height * 0.2),
        width: width * 0.6,
        height: height * 0.8,
      ),
      paint,
    );
  }

  void _drawCrown(Canvas canvas, Rect faceRect) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow;

    final centerX = faceRect.center.dx;
    final topY = faceRect.top - faceRect.height * 0.1;
    final width = faceRect.width * 0.6;

    final path = Path();
    path.moveTo(centerX - width / 2, faceRect.top);
    path.lineTo(centerX - width / 2, topY);
    path.lineTo(centerX - width / 4, faceRect.top - faceRect.height * 0.05);
    path.lineTo(centerX, topY - faceRect.height * 0.05);
    path.lineTo(centerX + width / 4, faceRect.top - faceRect.height * 0.05);
    path.lineTo(centerX + width / 2, topY);
    path.lineTo(centerX + width / 2, faceRect.top);
    path.close();

    canvas.drawPath(path, paint);

    // Crown spikes
    final spikePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow[700]!;

    for (int i = -1; i <= 1; i++) {
      final spikeX = centerX + (width / 4) * i;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(spikeX, topY - faceRect.height * 0.03),
          width: width * 0.1,
          height: faceRect.height * 0.06,
        ),
        spikePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
