import 'dart:ui';
import 'package:flutter/material.dart';

/// Фон с размытыми цветными пятнами — как на скринах Регистрация/Вход.
class BlobBackground extends StatelessWidget {
  final Widget child;
  final Color base;
  const BlobBackground({
    super.key,
    required this.child,
    this.base = const Color(0xFFF2F2F5),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: base),
        Positioned(
          top: -60,
          left: -40,
          child: _blob(180, const Color(0xFF7E97C7)),
        ),
        Positioned(
          top: 40,
          right: -60,
          child: _blob(220, const Color(0xFF3D5A8A)),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: _blob(200, const Color(0xFFB9B9C6)),
        ),
        Positioned(
          bottom: 60,
          right: -40,
          child: _blob(160, const Color(0xFF8A6BFF).withValues(alpha: 0.6)),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
        child,
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
