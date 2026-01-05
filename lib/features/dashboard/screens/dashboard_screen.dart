import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/auth/providers/auth_provider.dart';
import 'package:rcl_dashboard/features/dashboard/providers/dashboard_provider.dart';
import 'package:rcl_dashboard/features/dashboard/widgets/dashboard_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardProvider>().refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006AFF)),
              ),
            );
          }

          final dashboard = provider.dashboard;
          final authProvider = context.read<AuthProvider>();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Premium Dark Header
                _buildHeader(authProvider),
                // Content area with padding
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Cards Grid
                      _buildKPIGrid(dashboard),
                      SizedBox(height: 32),
                      // Quick Actions
                      _buildQuickActions(context),
                      SizedBox(height: 32),
                      // Performance Charts
                      _buildPerformanceSection(dashboard),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1F3F), // Deep navy
            Color(0xFF1B3A5F), // Dark blue
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top icons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.menu, color: Colors.white, size: 24),
                  ),
                ),
                // RCL Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: Color(0xFF1B5F9D),
                    child: Center(
                      child: Text(
                        'RCL',
                        style: TextStyle(
                          color: Color(0xFF06A8FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.notifications_none,
                        color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Greeting text
            Text(
              'Welcome back,',
              style: TextStyle(
                color: Color(0xFFB0B8C1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),
            Text(
              authProvider.user?.email?.split('@')[0].toTitleCase() ??
                  'Demo User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid(dashboard) {
    if (dashboard == null) {
      return SizedBox.shrink();
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        _buildStatCard(
          icon: Icons.directions_car_filled,
          iconBg: Color(0xFFE3F2FD),
          iconColor: Color(0xFF006AFF),
          value: dashboard.totalCars.toString(),
          label: 'Total Cars',
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          iconBg: Color(0xFFE8F5E9),
          iconColor: Color(0xFF10B981),
          value: dashboard.availableCars.toString(),
          label: 'Available',
          badge: '8%',
          badgeColor: Color(0xFF10B981),
        ),
        _buildStatCard(
          icon: Icons.assignment_outlined,
          iconBg: Color(0xFFF3E5F5),
          iconColor: Color(0xFF8B5CF6),
          value: dashboard.activeRentals.toString(),
          label: 'Active Rentals',
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          iconBg: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
          value: '\$${dashboard.todayRevenue.toStringAsFixed(0)}',
          label: 'Today\'s Revenue',
          badge: '12%',
          badgeColor: Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Color(0xFF10B981)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up,
                          size: 12, color: badgeColor ?? Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor ?? Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          // Value and label
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.add_circle_outline,
              label: 'Add Booking',
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.person_add_outlined,
              label: 'Add Customer',
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.directions_car_outlined,
              label: 'Add Vehicle',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFDEE9FF),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Color(0xFF006AFF),
                size: 28,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(dashboard) {
    if (dashboard == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                title: 'Weekly Rentals',
                chart: DailyRentalsChart(data: dashboard.dailyRentals),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                title: 'Revenue Trend',
                chart: RevenueChart(data: dashboard.revenueData),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget chart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(height: 120, child: chart),
        ],
      ),
    );
  }
}

extension on String {
  String toTitleCase() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
