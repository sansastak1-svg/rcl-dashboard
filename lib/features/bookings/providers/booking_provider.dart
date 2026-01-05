import 'package:flutter/material.dart';
import 'package:rcl_dashboard/features/bookings/models/booking_models.dart';

class BookingProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Booking> _bookings = [];
  List<Booking> _archivedBookings = [];
  String? _error;
  String _filterTab = 'active'; // active, upcoming, completed, cancelled, archived

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterTab => _filterTab;

  // Get filtered bookings based on current tab
  List<Booking> get bookings {
    switch (_filterTab) {
      case 'active':
        return _bookings.where((b) => b.status == 'active' && !b.isArchived).toList();
      case 'upcoming':
        return _bookings.where((b) => b.status == 'upcoming' && !b.isArchived).toList();
      case 'completed':
        return _bookings.where((b) => b.status == 'completed' && !b.isArchived).toList();
      case 'cancelled':
        return _bookings.where((b) => b.status == 'cancelled' && !b.isArchived).toList();
      case 'archived':
        return _archivedBookings;
      default:
        return [];
    }
  }

  // Get all bookings (for fleet availability checks)
  List<Booking> get allActiveBookings =>
      _bookings.where((b) => b.status == 'active' && !b.isArchived).toList();

  // Statistics
  int get totalActiveBookings => allActiveBookings.length;
  double get totalRevenue =>
      _bookings.fold(0.0, (sum, booking) => sum + booking.totalPrice);
  double get pendingRevenue => _bookings
      .where((b) => b.paymentStatus != 'completed')
      .fold(0.0, (sum, booking) => sum + booking.remainingPayment);

  BookingProvider() {
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      _bookings = [
        Booking(
          id: 'BK001',
          customerId: 'CUST001',
          customerName: 'John Doe',
          customerPhone: '+1234567890',
          vehicleId: 'VH001',
          vehicleModel: 'Toyota Camry',
          vehicleColor: 'Silver',
          licensePlate: 'ABC-123',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 7)),
          dailyRate: 200.0,
          totalPrice: 1400.0,
          paidAmount: 700.0,
          status: 'active',
          paymentStatus: 'partial',
          notes: 'Business trip rental',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        Booking(
          id: 'BK002',
          customerId: 'CUST002',
          customerName: 'Jane Smith',
          customerPhone: '+1234567891',
          vehicleId: 'VH002',
          vehicleModel: 'Honda Civic',
          vehicleColor: 'Blue',
          licensePlate: 'XYZ-789',
          startDate: DateTime.now().add(Duration(days: 3)),
          endDate: DateTime.now().add(Duration(days: 10)),
          dailyRate: 150.0,
          totalPrice: 1050.0,
          paidAmount: 1050.0,
          status: 'upcoming',
          paymentStatus: 'completed',
          notes: 'Vacation trip',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        ),
      ];

      _archivedBookings = [
        Booking(
          id: 'BK003',
          customerId: 'CUST003',
          customerName: 'Mike Johnson',
          customerPhone: '+1234567892',
          vehicleId: 'VH003',
          vehicleModel: 'Ford Mustang',
          vehicleColor: 'Red',
          licensePlate: 'MUS-456',
          startDate: DateTime.now().subtract(Duration(days: 14)),
          endDate: DateTime.now().subtract(Duration(days: 7)),
          dailyRate: 300.0,
          totalPrice: 2100.0,
          paidAmount: 2100.0,
          status: 'completed',
          paymentStatus: 'completed',
          notes: 'Weekend getaway',
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          isArchived: true,
        ),
      ];

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilterTab(String tab) {
    _filterTab = tab;
    notifyListeners();
  }

  // Check if vehicle is available for dates (no overlapping active bookings)
  bool isVehicleAvailable(String vehicleId, DateTime startDate, DateTime endDate) {
    return !allActiveBookings.any((booking) {
      if (booking.vehicleId != vehicleId) return false;
      // Check for date overlap
      return !(endDate.isBefore(booking.startDate) ||
          startDate.isAfter(booking.endDate));
    });
  }

  // Get conflicting bookings for a vehicle
  List<Booking> getConflictingBookings(
      String vehicleId, DateTime startDate, DateTime endDate) {
    return allActiveBookings.where((booking) {
      if (booking.vehicleId != vehicleId) return false;
      return !(endDate.isBefore(booking.startDate) ||
          startDate.isAfter(booking.endDate));
    }).toList();
  }

  Future<bool> createBooking(CreateBookingRequest request) async {
    // Validate no double booking
    if (!isVehicleAvailable(request.vehicleId, request.startDate, request.endDate)) {
      _error = 'Vehicle is already booked for these dates';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final newBooking = Booking(
        id: 'BK${DateTime.now().millisecondsSinceEpoch}',
        customerId: request.customerId,
        customerName: request.customerName,
        customerPhone: request.customerPhone,
        vehicleId: request.vehicleId,
        vehicleModel: request.vehicleModel,
        vehicleColor: request.vehicleColor,
        licensePlate: request.licensePlate,
        startDate: request.startDate,
        endDate: request.endDate,
        dailyRate: request.dailyRate,
        totalPrice: request.totalPrice,
        paidAmount: 0,
        status: request.startDate.isBefore(DateTime.now()) ? 'active' : 'upcoming',
        paymentStatus: 'pending',
        notes: request.notes,
        createdAt: DateTime.now(),
      );

      _bookings.insert(0, newBooking);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBooking(UpdateBookingRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _bookings.indexWhere((b) => b.id == request.id);
      if (index != -1) {
        final booking = _bookings[index];
        final updated = booking.copyWith(
          endDate: request.endDate,
          status: request.status,
          paidAmount: request.paidAmount,
          notes: request.notes,
          isArchived: request.isArchived,
        );

        if (request.isArchived == true) {
          _archivedBookings.add(updated);
          _bookings.removeAt(index);
        } else {
          _bookings[index] = updated;
        }

        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Booking not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        _bookings[index] = booking.copyWith(status: 'cancelled');
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Booking not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        final completed = booking.copyWith(status: 'completed');
        _archivedBookings.add(completed);
        _bookings.removeAt(index);
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Booking not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payBooking(String bookingId, double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        final newPaidAmount = booking.paidAmount + amount;
        final newStatus = newPaidAmount >= booking.totalPrice ? 'completed' : 'partial';

        _bookings[index] = booking.copyWith(
          paidAmount: newPaidAmount,
          paymentStatus: newStatus,
        );
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Booking not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auto-archive completed bookings
  void autoArchiveCompletedBookings() {
    final completed = _bookings.where((b) => b.isEnded && b.status == 'active').toList();
    for (var booking in completed) {
      final index = _bookings.indexOf(booking);
      if (index != -1) {
        final archived = booking.copyWith(
          status: 'completed',
          isArchived: true,
        );
        _archivedBookings.add(archived);
        _bookings.removeAt(index);
      }
    }
    notifyListeners();
  }

  // Filter archive by year and month
  List<Booking> getArchivedBookingsByYearMonth(int year, int month) {
    return _archivedBookings.where((b) {
      return b.createdAt.year == year && b.createdAt.month == month;
    }).toList();
  }

  // Filter archive by vehicle
  List<Booking> getArchivedBookingsByVehicle(String vehicleId) {
    return _archivedBookings.where((b) => b.vehicleId == vehicleId).toList();
  }

  // Filter archive by customer
  List<Booking> getArchivedBookingsByCustomer(String customerId) {
    return _archivedBookings.where((b) => b.customerId == customerId).toList();
  }

  Future<void> refreshBookings() async {
    autoArchiveCompletedBookings();
    await _loadBookings();
  }
}
