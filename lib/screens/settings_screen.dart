import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../build_context_ext.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<GarageBloc, GarageState>(
      listener: (context, state) {
        if (state.status == GarageStatus.unauthenticated &&
            !state.isAuthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<GarageBloc, GarageState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                l10n.settings,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle(l10n.appearance),
                _buildSettingCard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.dark_mode_rounded,
                      color: Colors.blueAccent,
                    ),
                    title: Text(l10n.darkTheme),
                    trailing: Switch(
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        context.read<GarageBloc>().add(
                          ChangeTheme(value ? ThemeMode.dark : ThemeMode.light),
                        );
                      },
                      activeColor: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(l10n.language),
                _buildSettingCard(
                  child: ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: Colors.blueAccent,
                    ),
                    title: Text(l10n.language),
                    trailing: DropdownButton<Locale>(
                      value: state.locale,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Text(l10n.english),
                        ),
                        DropdownMenuItem(
                          value: const Locale('vi'),
                          child: Text(l10n.vietnamese),
                        ),
                      ],
                      onChanged: (locale) {
                        if (locale != null) {
                          context.read<GarageBloc>().add(ChangeLocale(locale));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(
                  l10n.localeName == 'vi' ? 'Bảo dưỡng' : 'Maintenance',
                ),
                _buildSettingCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.build_rounded, color: Colors.blueAccent, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.localeName == 'vi'
                                        ? 'Chu kỳ bảo dưỡng mặc định'
                                        : 'Default service interval',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.localeName == 'vi'
                                        ? 'Áp dụng cho tất cả xe (có thể ghi đè cho từng xe)'
                                        : 'Applies to all vehicles — can override per vehicle',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.localeName == 'vi'
                                    ? '${state.maintenanceIntervalMonths} tháng'
                                    : '${state.maintenanceIntervalMonths} months',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            activeTrackColor: Colors.blueAccent,
                            inactiveTrackColor: Colors.blueAccent.withOpacity(0.2),
                            thumbColor: Colors.blueAccent,
                            overlayColor: Colors.blueAccent.withOpacity(0.1),
                            valueIndicatorColor: Colors.blueAccent,
                            showValueIndicator: ShowValueIndicator.always,
                            valueIndicatorTextStyle:
                                const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          child: Slider(
                            value: state.maintenanceIntervalMonths
                                .clamp(3, 9)
                                .toDouble(),
                            min: 3,
                            max: 9,
                            divisions: 6,
                            label: l10n.localeName == 'vi'
                                ? '${state.maintenanceIntervalMonths} tháng'
                                : '${state.maintenanceIntervalMonths} months',
                            onChanged: (value) {
                              context.read<GarageBloc>().add(
                                    ChangeMaintenanceInterval(value.round()),
                                  );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.localeName == 'vi' ? '3 tháng' : '3 months',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              Text(
                                l10n.localeName == 'vi' ? '9 tháng' : '9 months',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
