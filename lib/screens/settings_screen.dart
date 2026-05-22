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
