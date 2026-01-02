import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../theme/garage_theme.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        final vehicle = state.vehicles.firstWhere((v) => v.id == vehicleId);
        final records = state.maintenanceRecords
            .where((r) => r.vehicleId == vehicleId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(vehicle.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/edit_vehicle', extra: vehicle),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, vehicle.id),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                    child: Column(
                      children: [
                        _buildVehicleHeader(vehicle),
                        const SizedBox(height: 30),
                        _buildStatsGrid(vehicle),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Service History',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push('/add_maintenance/${vehicle.id}'),
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add Record'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                records.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(child: Text('No records yet', style: TextStyle(color: Colors.white54))),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final record = records[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: GlassWidget(
                                padding: const EdgeInsets.all(16),
                                child: ListTile(
                                  onTap: () => context.push('/edit_maintenance', extra: record),
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.build_circle_rounded, color: Colors.blueAccent),
                                  ),
                                  title: Text(
                                    record.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    DateFormat.yMMMd().format(record.date),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${record.cost.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${record.mileageAtService.toInt()} km',
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: records.length,
                        ),
                      ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/add_maintenance/${vehicle.id}'),
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildVehicleHeader(vehicle) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
          ),
          child: Icon(_getVehicleIcon(vehicle.type), size: 60, color: Colors.blueAccent),
        ),
        const SizedBox(height: 16),
        Text(
          vehicle.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          '${vehicle.year} ${vehicle.type}',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(vehicle) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Mileage', '${vehicle.currentMileage.toInt()}', 'km'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Status', 'Good', ''),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return GlassWidget(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 14, color: Colors.white54)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Vehicle?'),
        content: const Text('This will permanently remove this vehicle and all its history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<GarageBloc>().add(DeleteVehicle(id));
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'car': return Icons.directions_car_rounded;
      case 'motorcycle': return Icons.two_wheeler_rounded;
      case 'bicycle': return Icons.pedal_bike_rounded;
      case 'truck': return Icons.local_shipping_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }
}
