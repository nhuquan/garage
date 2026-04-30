import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../build_context_ext.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _deleteError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<GarageBloc, GarageState>(
      listener: (context, state) {
        if (state.status == GarageStatus.unauthenticated && !state.isAuthenticated) {
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
              title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildUserGreeting(context, state, l10n),
                const SizedBox(height: 30),
                _buildSectionTitle(l10n.appearance),
                _buildSettingCard(
                  child: ListTile(
                    leading: const Icon(Icons.dark_mode_rounded, color: Colors.blueAccent),
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
                    leading: const Icon(Icons.language_rounded, color: Colors.blueAccent),
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
                _buildDangerZone(context, l10n),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.read<GarageBloc>().add(LogoutUser()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.2),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (_deleteError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _deleteError!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            l10n.dangerZone.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.redAccent),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _confirmDeleteAccount(context, l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          icon: const Icon(Icons.delete_forever_rounded),
          label: Text(l10n.deleteAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppLocalizations l10n) {
    final passwordController = TextEditingController();
    String? passwordError;
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(l10n.deleteAccountTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deleteAccountWarning,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.enterPassword,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      errorText: passwordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color?.withOpacity(0.05),
                    ),
                    onChanged: (_) {
                      if (passwordError != null) {
                        passwordError = null;
                        setDialogState(() {});
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: Text(l10n.localeName == 'vi' ? 'Hủy' : 'Cancel'),
                ),
                FilledButton(
                  onPressed: isDeleting || passwordController.text.isEmpty
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                            passwordError = null;
                          });

                          try {
                            context.read<GarageBloc>().add(DeleteAccount(passwordController.text));
                            Navigator.pop(ctx);
                          } catch (e) {
                            setDialogState(() {
                              isDeleting = false;
                              passwordError = l10n.incorrectPassword;
                            });
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.delete),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      passwordController.dispose();
    });
  }

  Widget _buildUserGreeting(BuildContext context, GarageState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: const Icon(Icons.person_rounded, size: 30, color: Colors.blueAccent),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.greeting(state.username ?? 'User'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Garage Member',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.blueAccent),
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
