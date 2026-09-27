import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawing_provider.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);

    return GestureDetector(
      onPanStart: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);

        if (drawingProvider.currentTool == DrawingTool.text) {
          _showTextDialog(context, localPosition, drawingProvider);
          return;
        }

        if (drawingProvider.currentTool == DrawingTool.image) {
          drawingProvider.importImage(localPosition);
          return;
        }

        drawingProvider.addPath(DrawingPath(
          points: [localPosition],
          color: drawingProvider.isEraserMode
              ? Colors.transparent
              : drawingProvider.currentColor,
          strokeWidth: drawingProvider.currentStrokeWidth,
          toolType: drawingProvider.currentTool,
        ));
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        drawingProvider.updateLastPath(localPosition);
      },
      child: CustomPaint(
        painter: DrawingPainter(
          paths: drawingProvider.paths,
          textElements: drawingProvider.textElements,
          imageElements: drawingProvider.imageElements,
          backgroundImage: drawingProvider.backgroundImage,
          gridType: drawingProvider.gridType,
        ),
        size: Size.infinite,
      ),
    );
  }

  void _showTextDialog(
      BuildContext context, Offset position, DrawingProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Text Annotation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type text here...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addText(controller.text, position);
              }
              Navigator.pop(context);
            },
            child: const Text('Add Text',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final List<TextElement> textElements;
  final List<ImageElement> imageElements;
  final ui.Image? backgroundImage;
  final CanvasGridType gridType;

  DrawingPainter({
    required this.paths,
    required this.textElements,
    required this.imageElements,
    this.backgroundImage,
    required this.gridType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Canvas Background
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(),
            backgroundImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      // Default Studio Dark Slate Canvas
      final bgPaint = Paint()..color = const Color(0xFF13141F);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    }

    // 2. Draw Grid Overlay if enabled
    _drawGridOverlay(canvas, size);

    // 3. Save Layer for paths (enables eraser blend mode clear)
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (var path in paths) {
      final paint = Paint()
        ..color = path.color
        ..strokeWidth = path.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (path.toolType == DrawingTool.eraser) {
        paint.blendMode = BlendMode.clear;
      }

      switch (path.toolType) {
        case DrawingTool.pen:
        case DrawingTool.eraser:
          _drawFreehand(canvas, path, paint);
          break;
        case DrawingTool.line:
          _drawLine(canvas, path, paint);
          break;
        case DrawingTool.rectangle:
          _drawRectangle(canvas, path, paint);
          break;
        case DrawingTool.circle:
          _drawCircle(canvas, path, paint);
          break;
        case DrawingTool.triangle:
          _drawTriangle(canvas, path, paint);
          break;
        case DrawingTool.arrow:
          _drawArrow(canvas, path, paint);
          break;
        case DrawingTool.star:
          _drawStar(canvas, path, paint);
          break;
        case DrawingTool.text:
        case DrawingTool.image:
          break;
      }
    }

    // 4. Draw Draggable Image Elements
    for (var imageElement in imageElements) {
      _drawImageElement(canvas, imageElement);
    }

    // 5. Draw Text Elements
    for (var textElement in textElements) {
      _drawText(canvas, textElement);
    }

    canvas.restore();
  }

  void _drawGridOverlay(Canvas canvas, Size size) {
    if (gridType == CanvasGridType.none) return;

    final isDark = backgroundImage == null;
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);

    if (gridType == CanvasGridType.dots) {
      final dotPaint = Paint()
        ..color = gridColor
        ..style = PaintingStyle.fill;
      const double spacing = 28.0;

      for (double x = spacing; x < size.width; x += spacing) {
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
        }
      }
    } else if (gridType == CanvasGridType.grid) {
      final linePaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1.0;
      const double spacing = 36.0;

      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      }
    }
  }

  void _drawText(Canvas canvas, TextElement textElement) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: textElement.text,
        style: TextStyle(
          color: textElement.color,
          fontSize: textElement.fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
            )
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, textElement.position - Offset(0, textPainter.height / 2));
  }

  void _drawFreehand(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length > 1) {
      for (int i = 0; i < path.points.length - 1; i++) {
        canvas.drawLine(path.points[i], path.points[i + 1], paint);
      }
    } else if (path.points.isNotEmpty) {
      canvas.drawCircle(
          path.points[0], path.strokeWidth / 2, paint..style = PaintingStyle.fill);
    }
  }

  void _drawLine(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      canvas.drawLine(path.points[0], path.points[1], paint);
    }
  }

  void _drawRectangle(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      canvas.drawRect(Rect.fromPoints(path.points[0], path.points[1]), paint);
    }
  }

  void _drawCircle(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      final rect = Rect.fromPoints(path.points[0], path.points[1]);
      canvas.drawOval(rect, paint);
    }
  }

  void _drawTriangle(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      final rect = Rect.fromPoints(path.points[0], path.points[1]);
      final trianglePath = Path()
        ..moveTo(rect.left + rect.width / 2, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close();
      canvas.drawPath(trianglePath, paint);
    }
  }

  void _drawArrow(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      final start = path.points[0];
      final end = path.points[1];
      canvas.drawLine(start, end, paint);

      final dX = end.dx - start.dx;
      final dY = end.dy - start.dy;
      final angle = math.atan2(dY, dX);
      const headLength = 16.0;
      const headAngle = math.pi / 6;

      final pathHead = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - headLength * math.cos(angle - headAngle),
            end.dy - headLength * math.sin(angle - headAngle))
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - headLength * math.cos(angle + headAngle),
            end.dy - headLength * math.sin(angle + headAngle));
      canvas.drawPath(pathHead, paint);
    }
  }

  void _drawStar(Canvas canvas, DrawingPath path, Paint paint) {
    if (path.points.length >= 2) {
      final rect = Rect.fromPoints(path.points[0], path.points[1]);
      final center = rect.center;
      final radius = rect.width / 2;
      final starPath = Path();

      for (int i = 0; i < 10; i++) {
        final double angle = math.pi / 5 * i - math.pi / 2;
        final double r = i % 2 == 0 ? radius : radius / 2.5;
        final double x = center.dx + math.cos(angle) * r;
        final double y = center.dy + math.sin(angle) * r;
        if (i == 0) {
          starPath.moveTo(x, y);
        } else {
          starPath.lineTo(x, y);
        }
      }
      starPath.close();
      canvas.drawPath(starPath, paint);
    }
  }

  void _drawImageElement(Canvas canvas, ImageElement element) {
    canvas.save();
    canvas.translate(element.position.dx, element.position.dy);
    canvas.rotate(element.rotation);
    canvas.scale(element.scale);
    canvas.drawImage(element.image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
