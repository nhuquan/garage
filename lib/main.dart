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
import 'widgets/garage_background.dart';

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

class PageLoader extends StatefulWidget {
  final Widget child;
  const PageLoader({super.key, required this.child});

  @override
  State<PageLoader> createState() => _PageLoaderState();
}

class _PageLoaderState extends State<PageLoader> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GarageBackground(
      isLoading: _isLoading,
      child: _isLoading ? const SizedBox.expand() : widget.child,
    );
  }
}

Page<T> buildPageWithTransition<T>(Widget child) {
  return CustomTransitionPage<T>(
    child: PageLoader(child: child),
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
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
          pageBuilder: (context, state) => buildPageWithTransition(const LoginScreen()),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => buildPageWithTransition(const DashboardScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => buildPageWithTransition(const SettingsScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/add_vehicle',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => buildPageWithTransition(const AddEditVehicleScreen()),
        ),
        GoRoute(
          path: '/edit_vehicle',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final vehicle = state.extra as Vehicle;
            return buildPageWithTransition(AddEditVehicleScreen(vehicle: vehicle));
          },
        ),
        GoRoute(
          path: '/vehicle_details/:id',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return buildPageWithTransition(VehicleDetailsScreen(vehicleId: id));
          },
        ),
        GoRoute(
          path: '/add_maintenance/:vehicleId',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final vehicleId = state.pathParameters['vehicleId']!;
            return buildPageWithTransition(AddEditMaintenanceScreen(vehicleId: vehicleId));
          },
        ),
        GoRoute(
          path: '/edit_maintenance',
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final item = state.extra as MaintenanceItem;
            return buildPageWithTransition(AddEditMaintenanceScreen(
                vehicleId: item.vehicleId, item: item));
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GarageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: child),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ColorFilter.mode(
                isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                BlendMode.overlay,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E2E).withOpacity(0.85)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(context, Icons.home_rounded, l10n.home, '/'),
                    _buildNavItem(context, Icons.settings_rounded, l10n.settings,
                        '/settings'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, String path) {
    final location = GoRouterState.of(context).uri.toString();
    final isSelected = location == path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? Colors.blueAccent
        : (isDark ? Colors.white54 : Colors.grey[600]);

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
