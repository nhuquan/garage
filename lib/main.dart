import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/garage_bloc.dart';
import 'blocs/garage_event.dart';
import 'blocs/garage_state.dart';
import 'models/maintenance_item.dart';
import 'models/vehicle.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_edit_vehicle_screen.dart';
import 'screens/vehicle_details_screen.dart';
import 'screens/add_edit_maintenance_screen.dart';
import 'screens/login_screen.dart';
import 'theme/garage_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final garageState = context.read<GarageBloc>().state;
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
          builder: (context, state) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.read<GarageBloc>().add(LogoutUser()),
                child: const Text('Logout'),
              ),
            );
          },
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GarageBloc()..add(CheckAuth()),
      child: BlocBuilder<GarageBloc, GarageState>(
        builder: (context, state) {
          // Force router refresh when auth state changes
          return MaterialApp.router(
            key: ValueKey(state.isAuthenticated),
            title: 'Garage',
            debugShowCheckedModeBanner: false,
            theme: GarageTheme.darkTheme,
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: child,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: GlassWidget(
          borderRadius: 30,
          opacity: 0.1,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', '/'),
              _buildNavItem(context, Icons.history_rounded, 'History', '/history'),
              _buildNavItem(context, Icons.settings_rounded, 'Settings', '/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String path) {
    final location = GoRouterState.of(context).uri.toString();
    final isSelected = location == path;
    
    return InkWell(
      onTap: () => context.go(path),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.white54,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blueAccent : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
