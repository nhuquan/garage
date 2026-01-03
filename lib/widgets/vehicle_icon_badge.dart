import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleIconBadge extends StatelessWidget {
  final Vehicle vehicle;
  final bool isDark;
  final double size;
  final double iconSize;
  final double badgeSize;
  final double badgePadding;

  const VehicleIconBadge({
    super.key,
    required this.vehicle,
    required this.isDark,
    this.size = 100,
    this.iconSize = 50,
    this.badgeSize = 24,
    this.badgePadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
          ),
          child: Icon(vehicle.vehicleIcon, size: iconSize, color: Colors.blueAccent),
        ),
        if (vehicle.brandLogo != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(badgePadding),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                vehicle.brandLogo!,
                width: badgeSize,
                height: badgeSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
