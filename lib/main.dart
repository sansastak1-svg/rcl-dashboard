import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/theme/app_theme.dart';
import 'package:rcl_dashboard/features/auth/providers/auth_provider.dart';
import 'package:rcl_dashboard/features/auth/screens/login_screen.dart';
import 'package:rcl_dashboard/features/home_screen.dart';
import 'package:rcl_dashboard/features/dashboard/providers/dashboard_provider.dart';
import 'package:rcl_dashboard/features/bookings/providers/booking_provider.dart';
import 'package:rcl_dashboard/features/customers/providers/customer_provider.dart';

void main() {
  runApp(const RCLDashboardApp());
}

class RCLDashboardApp extends StatelessWidget {
  const RCLDashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
      ],
      child: MaterialApp(
        title: 'RCL Dashboard',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
