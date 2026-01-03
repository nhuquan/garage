import 'package:flutter/material.dart';

class GarageBackground extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const GarageBackground({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F0F0F),
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5F7FA),
                    Color(0xFFE4E9F2),
                  ],
                ),
        ),
        child: Stack(
          children: [
            child,
            if (isLoading)
              Container(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
