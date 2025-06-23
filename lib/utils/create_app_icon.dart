import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 1024,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
            Colors.blue.shade300,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ظل الكتاب
          Container(
            width: 600,
            height: 700,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            transform: Matrix4.translationValues(5, 5, 0),
          ),
          // الكتاب الرئيسي
          Container(
            width: 600,
            height: 700,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة المكتبة
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.library_books,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // خطوط الكتاب
                ...List.generate(5, (index) => 
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 3,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 