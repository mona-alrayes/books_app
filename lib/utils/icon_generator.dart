import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

class IconGenerator {
  static Future<void> generateAppIcon() async {
    // إنشاء أيقونة مكتبة الكتب
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1024, 1024);
    
    // خلفية دائرية بتدرج أزرق
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade700,
          Colors.blue.shade500,
          Colors.blue.shade300,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );
    
    // رسم كتاب أبيض في المنتصف
    final bookPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.6,
        height: size.height * 0.7,
      ),
      const Radius.circular(20),
    );
    
    // ظل الكتاب
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawRRect(
      bookRect.shift(const Offset(8, 8)),
      shadowPaint,
    );
    
    // الكتاب الرئيسي
    canvas.drawRRect(bookRect, bookPaint);
    
    // رسم أيقونة المكتبة في أعلى الكتاب
    final iconPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    final iconSize = size.width * 0.25;
    final iconRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.35),
      width: iconSize,
      height: iconSize,
    );
    
    // رسم أيقونة بسيطة للكتب
    final iconPath = Path();
    iconPath.moveTo(iconRect.left + iconSize * 0.2, iconRect.top + iconSize * 0.3);
    iconPath.lineTo(iconRect.left + iconSize * 0.8, iconRect.top + iconSize * 0.3);
    iconPath.lineTo(iconRect.left + iconSize * 0.8, iconRect.top + iconSize * 0.7);
    iconPath.lineTo(iconRect.left + iconSize * 0.2, iconRect.top + iconSize * 0.7);
    iconPath.close();
    
    canvas.drawPath(iconPath, iconPaint);
    
    // رسم خطوط الكتب
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    
    for (int i = 0; i < 3; i++) {
      final x = iconRect.left + iconSize * 0.35 + (i * iconSize * 0.15);
      canvas.drawLine(
        Offset(x, iconRect.top + iconSize * 0.35),
        Offset(x, iconRect.top + iconSize * 0.65),
        linePaint,
      );
    }
    
    // رسم خطوط الكتاب في الأسفل
    final bookLinePaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 4; i++) {
      final y = size.height * 0.6 + (i * size.height * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.25, y),
        Offset(size.width * 0.75, y),
        bookLinePaint,
      );
    }
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // حفظ الأيقونة
    final file = File('assets/icon/app_icon.png');
    await file.writeAsBytes(bytes);
    
    print('تم إنشاء أيقونة التطبيق في: ${file.path}');
  }
} 