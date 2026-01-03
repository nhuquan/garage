import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/glass_widget.dart';
import '../models/vehicle.dart';
import '../widgets/vehicle_icon_badge.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: l10n.localeName);

    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        final vehicle = state.vehicles.firstWhere((v) => v.id == vehicleId);
        final records = state.maintenanceRecords
            .where((r) => r.vehicleId == vehicleId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(vehicle.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/edit_vehicle', extra: vehicle),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, vehicle.id, l10n),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      _buildVehicleHeader(vehicle, isDark),
                      const SizedBox(height: 30),
                      _buildStatsGrid(vehicle, isDark, l10n),
                      const SizedBox(height: 40),
                      GlassWidget(
                        padding: EdgeInsets.zero,
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            l10n.localeName == 'vi' ? 'Thông tin chi tiết' : 'Detailed Information',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  vehicle.description.isEmpty
                                      ? (l10n.localeName == 'vi' ? 'Không có mô tả' : 'No description available')
                                      : vehicle.description,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GlassWidget(
                        padding: EdgeInsets.zero,
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          title: Text(
                            l10n.maintenanceHistory,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: const Icon(Icons.history_rounded, color: Colors.blueAccent),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${records.length}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          children: [
                            if (records.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  l10n.noMaintenance,
                                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                itemCount: records.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return ListTile(
                                    onTap: () => context.push('/edit_maintenance', extra: record),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: record.type.icon,
                                    ),
                                    title: Text(
                                      record.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      DateFormat.yMMMd(l10n.localeName).format(record.date),
                                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (record.cost > 0)
                                          Text(
                                            currencyFormat.format(record.cost),
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        Text(
                                          '${record.mileageAtService.toInt()} km',
                                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add_maintenance/${vehicle.id}'),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildVehicleHeader(Vehicle vehicle, bool isDark) {
    return Column(
      children: [
        VehicleIconBadge(vehicle: vehicle, isDark: isDark),
        const SizedBox(height: 16),
        Text(
          vehicle.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '${vehicle.year} • ${vehicle.type}',
          style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Vehicle vehicle, bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(l10n.currentMileage, '${vehicle.currentMileage.toInt()}', 'km', isDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(l10n.year, '${vehicle.year}', '', isDark),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, bool isDark) {
    return GlassWidget(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.localeName == 'vi' ? 'Bạn có chắc chắn muốn xóa xe này không?' : 'Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.localeName == 'vi' ? 'Hủy' : 'Cancel')),
          TextButton(
            onPressed: () {
              context.read<GarageBloc>().add(DeleteVehicle(id));
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
