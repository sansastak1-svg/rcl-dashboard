import 'package:flutter/material.dart';
import 'package:rcl_dashboard/features/dashboard/models/dashboard_models.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Dashboard? _dashboard;
  String? _error;

  bool get isLoading => _isLoading;
  Dashboard? get dashboard => _dashboard;
  String? get error => _error;

  DashboardProvider() {
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));

      _dashboard = Dashboard(
        totalCars: 45,
        availableCars: 28,
        activeRentals: 17,
        todayRevenue: 3250.50,
        monthlyRevenue: 78500.00,
        dailyRentals: [
          DailyRental(date: 'Mon', count: 12),
          DailyRental(date: 'Tue', count: 15),
          DailyRental(date: 'Wed', count: 18),
          DailyRental(date: 'Thu', count: 14),
          DailyRental(date: 'Fri', count: 22),
          DailyRental(date: 'Sat', count: 19),
          DailyRental(date: 'Sun', count: 11),
        ],
        alerts: [
          Alert(
            id: '1',
            type: 'overdue',
            title: 'Overdue Rental',
            description: 'Vehicle ABC-123 rental overdue by 2 hours',
            createdAt: DateTime.now(),
          ),
          Alert(
            id: '2',
            type: 'maintenance',
            title: 'Maintenance Due',
            description: 'Vehicle XYZ-789 requires service soon',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
          ),
          Alert(
            id: '3',
            type: 'payment',
            title: 'Pending Payment',
            description: 'Customer awaits payment confirmation',
            createdAt: DateTime.now().subtract(Duration(hours: 3)),
          ),
        ],
        revenueData: [
          RevenueData(month: 'Jan', amount: 65000),
          RevenueData(month: 'Feb', amount: 72000),
          RevenueData(month: 'Mar', amount: 68000),
          RevenueData(month: 'Apr', amount: 78500),
          RevenueData(month: 'May', amount: 82000),
          RevenueData(month: 'Jun', amount: 75000),
        ],
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await _loadDashboard();
  }
}
