import 'package:flutter/material.dart';
import 'dart:ui';

class GarageTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
        surface: const Color(0xFF1A1A1A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static BoxDecoration glassDecoration({
    double opacity = 0.1,
    double blur = 15.0,
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }
}

class GlassWidget extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassWidget({
    super.key,
    required this.child,
    this.opacity = 0.05,
    this.blur = 20.0,
    this.borderRadius = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: GarageTheme.glassDecoration(
            opacity: opacity,
            blur: blur,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
