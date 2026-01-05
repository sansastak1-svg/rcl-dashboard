class Dashboard {
  final int totalCars;
  final int availableCars;
  final int activeRentals;
  final double todayRevenue;
  final List<DailyRental> dailyRentals;
  final List<Alert> alerts;
  final double monthlyRevenue;
  final List<RevenueData> revenueData;

  Dashboard({
    required this.totalCars,
    required this.availableCars,
    required this.activeRentals,
    required this.todayRevenue,
    required this.dailyRentals,
    required this.alerts,
    required this.monthlyRevenue,
    required this.revenueData,
  });
}

class DailyRental {
  final String date;
  final int count;

  DailyRental({required this.date, required this.count});
}

class Alert {
  final String id;
  final String type; // 'overdue', 'maintenance', 'payment'
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });
}

class RevenueData {
  final String month;
  final double amount;

  RevenueData({required this.month, required this.amount});
}
