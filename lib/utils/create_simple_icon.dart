import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';

class CreateSimpleIcon {
  static Future<void> createIcon() async {
    // إنشاء أيقونة بسيطة لمكتبة الكتب
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1024, 1024);
    
    // خلفية دائرية زرقاء
    final backgroundPaint = Paint()
      ..color = Colors.blue.shade700;
    
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
    
    canvas.drawRRect(bookRect, bookPaint);
    
    // رسم أيقونة المكتبة
    final iconPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;
    
    final iconSize = size.width * 0.3;
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
    
    // رسم خطوط الكتاب
    final bookLinePaint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 4;
    
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