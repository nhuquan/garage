import 'dart:ui';
import 'package:flutter/material.dart';

class GlassWidget extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassWidget({
    super.key,
    required this.child,
    this.opacity = 0.1,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
