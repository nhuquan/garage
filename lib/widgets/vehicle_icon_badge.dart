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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return Colors.green;
      case 'motorcycle':
      case 'moto':
        return Colors.blueAccent;
      case 'bicycle':
      case 'bike':
        return Colors.greenAccent;
      case 'truck':
        return Colors.deepPurpleAccent;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(vehicle.type);
    final hasBrand = vehicle.brandLogo != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                typeColor.withOpacity(0.2),
                typeColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: typeColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: hasBrand
                ? vehicle.brandLogo!.image(
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  )
                : ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [typeColor, typeColor.withOpacity(0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Icon(
                      vehicle.vehicleIcon,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        if (hasBrand)
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
              child: Icon(
                vehicle.vehicleIcon,
                size: badgeSize,
                color: typeColor,
              ),
            ),
          ),
      ],
    );
  }
}
