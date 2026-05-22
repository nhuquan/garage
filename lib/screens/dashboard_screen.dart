import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_state.dart';
import '../database/app_database.dart';
import '../widgets/glass_widget.dart';
import '../widgets/vehicle_icon_badge.dart';

/// Days until next service. Positive = upcoming, negative = overdue, null = no records.
int? _daysUntilService(
  Vehicle vehicle,
  List<MaintenanceItem> allRecords,
  int globalIntervalMonths,
) {
  final records = allRecords.where((r) => r.vehicleId == vehicle.id).toList();
  if (records.isEmpty) return null;

  final latest = records.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  final interval = vehicle.maintenanceIntervalMonths ?? globalIntervalMonths;

  final nextDate = DateTime(
    latest.date.year,
    latest.date.month + interval,
    latest.date.day,
  );
  final today = DateTime.now();
  return nextDate
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
}

/// Compact badge showing days remaining / overdue for next maintenance.
class _MaintenanceBadge extends StatelessWidget {
  final Vehicle vehicle;

  const _MaintenanceBadge({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        final days = _daysUntilService(
          vehicle,
          state.maintenanceRecords,
          state.maintenanceIntervalMonths,
        );

        if (days == null) {
          // No maintenance on record yet
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build_outlined, size: 16, color: Colors.grey),
          );
        }

        final Color color;
        final String label;

        if (days >= 20) {
          color = Colors.green;
          label = '+${days}d';
        } else if (days >= 0) {
          color = Colors.orange;
          label = '${days}d';
        } else {
          color = Colors.redAccent;
          label = '${days}d';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: BlocBuilder<GarageBloc, GarageState>(
        builder: (context, state) {
          if (state.status == GarageStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.vehicles.isEmpty) {
            return _EmptyDashboard(l10n: l10n);
          }

          // Group vehicles by type
          final groupedVehicles = <String, List<Vehicle>>{};
          for (final vehicle in state.vehicles) {
            final type = vehicle.type;
            if (!groupedVehicles.containsKey(type)) {
              groupedVehicles[type] = [];
            }
            groupedVehicles[type]!.add(vehicle);
          }

          // Sort types for consistent display
          final types = groupedVehicles.keys.toList()..sort();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              for (final type in types) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIcon(type),
                          size: 20,
                          color: Colors.blueAccent.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDisplayType(type, l10n),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: Colors.blueAccent.withOpacity(0.2),
                            thickness: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${groupedVehicles[type]!.length}',
                          style: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isMobile)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _VehicleListItem(
                            vehicle: groupedVehicles[type]![index]);
                      },
                      childCount: groupedVehicles[type]!.length,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _VehicleCard(
                              vehicle: groupedVehicles[type]![index]);
                        },
                        childCount: groupedVehicles[type]!.length,
                      ),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_vehicle'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'motorcycle':
      case 'moto':
        return Icons.two_wheeler_rounded;
      case 'bicycle':
      case 'bike':
        return Icons.pedal_bike_rounded;
      case 'truck':
        return Icons.local_shipping_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  String _getDisplayType(String type, dynamic l10n) {
    // Simple localization logic or fallback to type name
    switch (type.toLowerCase()) {
      case 'car':
        return l10n.localeName == 'vi' ? 'Ô tô' : 'Cars';
      case 'motorcycle':
      case 'moto':
        return l10n.localeName == 'vi' ? 'Xe máy' : 'Motorcycles';
      case 'bicycle':
      case 'bike':
        return l10n.localeName == 'vi' ? 'Xe đạp' : 'Bicycles';
      case 'truck':
        return l10n.localeName == 'vi' ? 'Xe tải' : 'Trucks';
      default:
        return type;
    }
  }
}

class _EmptyDashboard extends StatelessWidget {
  final dynamic l10n;

  const _EmptyDashboard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassWidget(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.garage_rounded, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                l10n.noVehicles,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/add_vehicle'),
                icon: const Icon(Icons.add),
                label: Text(l10n.addVehicle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/vehicle_details/${vehicle.id}'),
      child: GlassWidget(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: VehicleIconBadge(
                  vehicle: vehicle,
                  isDark: isDark,
                  size: 85,
                  iconSize: 45,
                  badgeSize: 20,
                  badgePadding: 5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              vehicle.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '${vehicle.year}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed_rounded, size: 14, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Text(
                    '${vehicle.currentKm.toInt()} km',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _MaintenanceBadge(vehicle: vehicle),
          ],
        ),
      ),
    );
  }
}

class _VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleListItem({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/vehicle_details/${vehicle.id}'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        child: GlassWidget(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              VehicleIconBadge(
                vehicle: vehicle,
                isDark: isDark,
                size: 60,
                iconSize: 30,
                badgeSize: 16,
                badgePadding: 4,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.year} • ${vehicle.currentKm.toInt()} km',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              _MaintenanceBadge(vehicle: vehicle),
            ],
          ),
        ),
      ),
    );
  }
}
