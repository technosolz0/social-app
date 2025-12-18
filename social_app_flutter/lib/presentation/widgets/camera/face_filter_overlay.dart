import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// ============================================
// lib/presentation/widgets/camera/face_filter_overlay.dart
// AR Face Filters using ML Kit
// ============================================

class FaceFilterOverlay extends StatefulWidget {
  final String? filter;

  const FaceFilterOverlay({super.key, this.filter});

  @override
  State<FaceFilterOverlay> createState() => _FaceFilterOverlayState();
}

class _FaceFilterOverlayState extends State<FaceFilterOverlay> {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  List<Face>? _faces;

  @override
  Widget build(BuildContext context) {
    if (widget.filter == null || _faces == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: FaceFilterPainter(
        faces: _faces!,
        filter: widget.filter!,
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}

class FaceFilterPainter extends CustomPainter {
  final List<Face> faces;
  final String filter;

  FaceFilterPainter({
    required this.faces,
    required this.filter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (final face in faces) {
      final rect = face.boundingBox;

      // Draw face bounding box
      canvas.drawRect(rect, paint);

      // Apply filter overlay based on filter type
      _applyFilterOverlay(canvas, face, filter);
    }
  }

  void _applyFilterOverlay(Canvas canvas, Face face, String filter) {
    final rect = face.boundingBox;

    switch (filter) {
      case 'Glasses':
        _drawGlasses(canvas, rect);
        break;
      case 'Hat':
        _drawHat(canvas, rect);
        break;
      case 'Mustache':
        _drawMustache(canvas, rect);
        break;
      case 'Crown':
        _drawCrown(canvas, rect);
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
