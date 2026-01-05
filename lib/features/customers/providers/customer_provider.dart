import 'package:flutter/material.dart';
import 'package:rcl_dashboard/features/customers/models/customer_models.dart';

class CustomerProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Customer> _customers = [];
  List<Customer> _blacklistedCustomers = [];
  String? _error;
  String _searchQuery = '';
  String _filterType = 'active'; // active, blacklisted, vip

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterType => _filterType;
  
  List<Customer> get customers {
    List<Customer> filtered;
    
    switch (_filterType) {
      case 'blacklisted':
        filtered = _blacklistedCustomers;
        break;
      case 'vip':
        filtered = _customers.where((c) => c.rentalCount >= 10).toList();
        break;
      case 'active':
      default:
        filtered = _customers.where((c) => c.outstandingPayment < 100).toList();
    }
    
    if (_searchQuery.isEmpty) return filtered;
    return filtered
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery))
        .toList();
  }

  // Statistics
  int get totalCustomers => _customers.length;
  int get vipCustomers => _customers.where((c) => c.rentalCount >= 10).length;
  int get customersWithOutstanding => _customers.where((c) => c.outstandingPayment > 0).length;
  
  double get totalOutstandingPayment => _customers.fold(0.0, (sum, c) => sum + c.outstandingPayment);
  double get totalRevenue => _customers.fold(0.0, (sum, c) => sum + c.totalRentals);
  double get averageRentalValue => totalCustomers == 0 ? 0 : totalRevenue / totalCustomers;

  CustomerProvider() {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));

      _customers = [
        Customer(
          id: 'CUST001',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          licenseNumber: 'DL-2023-001',
          licenseExpiry: DateTime.now().add(Duration(days: 180)),
          createdAt: DateTime.now().subtract(Duration(days: 365)),
          totalRentals: 4200.00,
          rentalCount: 12,
          outstandingPayment: 0,
          idProof: 'url',
          licenseProof: 'url',
          rentalHistory: ['BK001', 'BK002', 'BK003'],
        ),
        Customer(
          id: 'CUST002',
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+1234567891',
          licenseNumber: 'DL-2023-002',
          licenseExpiry: DateTime.now().add(Duration(days: 90)),
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          totalRentals: 2100.00,
          rentalCount: 6,
          outstandingPayment: 0,
          idProof: 'url',
          licenseProof: 'url',
          rentalHistory: ['BK004', 'BK005'],
        ),
        Customer(
          id: 'CUST003',
          name: 'Mike Johnson',
          email: 'mike@example.com',
          phone: '+1234567892',
          licenseNumber: 'DL-2023-003',
          licenseExpiry: DateTime.now().add(Duration(days: 200)),
          createdAt: DateTime.now().subtract(Duration(days: 90)),
          totalRentals: 1500.00,
          rentalCount: 5,
          outstandingPayment: 250.00,
          idProof: 'url',
          licenseProof: 'url',
          rentalHistory: ['BK006'],
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  Future<bool> createCustomer(CreateCustomerRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      // Validate license expiry
      if (request.licenseExpiry.isBefore(DateTime.now())) {
        _error = 'License has expired';
        notifyListeners();
        return false;
      }

      final newCustomer = Customer(
        id: 'CUST${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        email: request.email,
        phone: request.phone,
        licenseNumber: request.licenseNumber,
        licenseExpiry: request.licenseExpiry,
        createdAt: DateTime.now(),
        totalRentals: 0,
        rentalCount: 0,
        outstandingPayment: 0,
        idProof: request.idProof ?? '',
        licenseProof: request.licenseProof ?? '',
        rentalHistory: [],
      );

      _customers.insert(0, newCustomer);
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

  Future<bool> updateCustomer(UpdateCustomerRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _customers.indexWhere((c) => c.id == request.id);
      if (index != -1) {
        final customer = _customers[index];
        _customers[index] = Customer(
          id: customer.id,
          name: request.name ?? customer.name,
          email: request.email ?? customer.email,
          phone: request.phone ?? customer.phone,
          licenseNumber: request.licenseNumber ?? customer.licenseNumber,
          licenseExpiry: request.licenseExpiry ?? customer.licenseExpiry,
          createdAt: customer.createdAt,
          totalRentals: customer.totalRentals,
          rentalCount: customer.rentalCount,
          outstandingPayment: customer.outstandingPayment,
          idProof: customer.idProof,
          licenseProof: customer.licenseProof,
          rentalHistory: customer.rentalHistory,
        );
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Customer not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordPayment(String customerId, double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _customers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final customer = _customers[index];
        final newOutstanding = (customer.outstandingPayment - amount).clamp(0.0, double.infinity);
        
        _customers[index] = Customer(
          id: customer.id,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          licenseNumber: customer.licenseNumber,
          licenseExpiry: customer.licenseExpiry,
          createdAt: customer.createdAt,
          totalRentals: customer.totalRentals + amount,
          rentalCount: customer.rentalCount,
          outstandingPayment: newOutstanding,
          idProof: customer.idProof,
          licenseProof: customer.licenseProof,
          rentalHistory: customer.rentalHistory,
        );
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Customer not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blacklistCustomer(String customerId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _customers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final customer = _customers[index];
        _blacklistedCustomers.add(customer);
        _customers.removeAt(index);
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Customer not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unblacklistCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _blacklistedCustomers.indexWhere((c) => c.id == customerId);
      if (index != -1) {
        final customer = _blacklistedCustomers[index];
        _customers.insert(0, customer);
        _blacklistedCustomers.removeAt(index);
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Customer not found in blacklist');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      _customers.removeWhere((c) => c.id == customerId);
      _blacklistedCustomers.removeWhere((c) => c.id == customerId);
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

  // Get customer by ID
  Customer? getCustomerById(String customerId) {
    try {
      return _customers.firstWhere((c) => c.id == customerId);
    } catch (e) {
      return null;
    }
  }

  // Get customers with expiring license
  List<Customer> getCustomersWithExpiringLicense() {
    return _customers
        .where((c) => c.licenseExpiry.isBefore(DateTime.now().add(Duration(days: 30))))
        .toList();
  }

  // Get VIP customers
  List<Customer> getVIPCustomers() {
    return _customers.where((c) => c.rentalCount >= 10).toList();
  }

  // Get customers with outstanding payment
  List<Customer> getCustomersWithOutstandingPayment() {
    return _customers.where((c) => c.outstandingPayment > 0).toList();
  }

  Future<void> refreshCustomers() async {
    await _loadCustomers();
  }
}
