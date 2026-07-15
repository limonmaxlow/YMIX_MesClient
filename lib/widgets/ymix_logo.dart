import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Логотип "Y MIX": буква Y с сине-фиолетовым градиентом + белая надпись MIX.
class YMixLogo extends StatelessWidget {
  final double fontSize;
  const YMixLogo({super.key, this.fontSize = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.logoGradient,
          ).createShader(bounds),
          child: Text(
            'Y',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        Text(
          'MIX',
          style: TextStyle(
            fontSize: fontSize * 0.72,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
