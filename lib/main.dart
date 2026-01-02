import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/garage_bloc.dart';
import 'blocs/garage_event.dart';
import 'blocs/garage_state.dart';
import 'build_context_ext.dart';
import 'l10n/app_localizations.dart';
import 'models/maintenance_item.dart';
import 'models/vehicle.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_edit_vehicle_screen.dart';
import 'screens/vehicle_details_screen.dart';
import 'screens/add_edit_maintenance_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/garage_theme.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GarageBloc _garageBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _garageBloc = GarageBloc()
      ..add(InitSettings())
      ..add(CheckAuth());

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(_garageBloc.stream),
      redirect: (context, state) {
        final garageState = _garageBloc.state;
        final bool loggingIn = state.matchedLocation == '/login';

        if (!garageState.isAuthenticated) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const Center(child: Text('All History coming soon')),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/add_vehicle',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditVehicleScreen(),
        ),
        GoRoute(
          path: '/edit_vehicle',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final vehicle = state.extra as Vehicle;
            return AddEditVehicleScreen(vehicle: vehicle);
          },
        ),
        GoRoute(
          path: '/vehicle_details/:id',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return VehicleDetailsScreen(vehicleId: id);
          },
        ),
        GoRoute(
          path: '/add_maintenance/:vehicleId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return AddEditMaintenanceScreen(vehicleId: vehicleId);
          },
        ),
        GoRoute(
          path: '/edit_maintenance',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final item = state.extra as MaintenanceItem;
            return AddEditMaintenanceScreen(vehicleId: item.vehicleId, item: item);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _garageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _garageBloc,
      child: BlocBuilder<GarageBloc, GarageState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Garage',
            debugShowCheckedModeBanner: false,
            theme: GarageTheme.lightTheme,
            darkTheme: GarageTheme.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
        child: SafeArea(child: child),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, l10n.home, '/'),
              _buildNavItem(context, Icons.history_rounded, l10n.history, '/history'),
              _buildNavItem(context, Icons.settings_rounded, l10n.settings, '/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String path) {
    final location = GoRouterState.of(context).uri.toString();
    final isSelected = location == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected ? Colors.blueAccent : (isDark ? Colors.white54 : Colors.grey[600]);

    return InkWell(
      onTap: () => context.go(path),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
