import 'package:flutter/material.dart';
import 'package:rcl_dashboard/features/fleet/models/vehicle_models.dart';

class FleetProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Vehicle> _vehicles = [];
  List<Vehicle> _maintenanceHistory = [];
  String? _error;
  String _filterStatus = 'all'; // all, available, rented, maintenance
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  
  List<Vehicle> get vehicles {
    var filtered = _filterStatus == 'all'
        ? _vehicles
        : _vehicles.where((v) => v.status == _filterStatus).toList();
    
    if (_searchQuery.isEmpty) return filtered;
    return filtered
        .where((v) =>
            v.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            v.make.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Statistics
  int get totalVehicles => _vehicles.length;
  int get availableVehicles => _vehicles.where((v) => v.status == 'available').length;
  int get rentedVehicles => _vehicles.where((v) => v.status == 'rented').length;
  int get maintenanceVehicles => _vehicles.where((v) => v.status == 'maintenance').length;
  
  double get totalFleetValue => _vehicles.fold(0.0, (sum, v) => sum + (v.dailyRate * 30));
  double get dailyRevenuePotential => availableVehicles.toDouble() * _getAverageDailyRate();
  
  double _getAverageDailyRate() {
    if (_vehicles.isEmpty) return 0;
    return _vehicles.fold(0.0, (sum, v) => sum + v.dailyRate) / _vehicles.length;
  }

  FleetProvider() {
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(seconds: 1));

      _vehicles = [
        Vehicle(
          id: 'VH001',
          model: 'Camry',
          make: 'Toyota',
          licensePlate: 'ABC-123',
          color: 'Silver',
          year: 2023,
          status: 'available',
          dailyRate: 200.00,
          mileage: 15000,
          registrationExpiry: DateTime.now().add(Duration(days: 180)),
          insuranceExpiry: DateTime.now().add(Duration(days: 120)),
          lastMaintenanceDate: DateTime.now().subtract(Duration(days: 30)),
          nextMaintenanceDate: DateTime.now().add(Duration(days: 60)),
          transmissionType: 'automatic',
          seatCount: 5,
          fuelType: 'Hybrid',
          rentalHistory: ['BK001'],
        ),
        Vehicle(
          id: 'VH002',
          model: 'Civic',
          make: 'Honda',
          licensePlate: 'XYZ-789',
          color: 'Blue',
          year: 2023,
          status: 'available',
          dailyRate: 150.00,
          mileage: 8000,
          registrationExpiry: DateTime.now().add(Duration(days: 200)),
          insuranceExpiry: DateTime.now().add(Duration(days: 150)),
          lastMaintenanceDate: DateTime.now().subtract(Duration(days: 15)),
          nextMaintenanceDate: DateTime.now().add(Duration(days: 75)),
          transmissionType: 'manual',
          seatCount: 5,
          fuelType: 'Petrol',
          rentalHistory: ['BK002'],
        ),
        Vehicle(
          id: 'VH003',
          model: 'Mustang',
          make: 'Ford',
          licensePlate: 'MUS-456',
          color: 'Red',
          year: 2022,
          status: 'maintenance',
          dailyRate: 250.00,
          mileage: 22000,
          registrationExpiry: DateTime.now().add(Duration(days: 150)),
          insuranceExpiry: DateTime.now().add(Duration(days: 100)),
          lastMaintenanceDate: DateTime.now().subtract(Duration(days: 5)),
          nextMaintenanceDate: DateTime.now().add(Duration(days: 90)),
          transmissionType: 'automatic',
          seatCount: 5,
          fuelType: 'Petrol',
          rentalHistory: ['BK003'],
        ),
        Vehicle(
          id: 'VH004',
          model: '3 Series',
          make: 'BMW',
          licensePlate: 'BMW-456',
          color: 'Black',
          year: 2024,
          status: 'available',
          dailyRate: 300.00,
          mileage: 5000,
          registrationExpiry: DateTime.now().add(Duration(days: 365)),
          insuranceExpiry: DateTime.now().add(Duration(days: 365)),
          lastMaintenanceDate: DateTime.now(),
          nextMaintenanceDate: DateTime.now().add(Duration(days: 120)),
          transmissionType: 'automatic',
          seatCount: 5,
          fuelType: 'Diesel',
          rentalHistory: [],
        ),
      ];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> createVehicle(CreateVehicleRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final newVehicle = Vehicle(
        id: 'VH${DateTime.now().millisecondsSinceEpoch}',
        model: request.model,
        make: request.make,
        licensePlate: request.licensePlate,
        color: request.color,
        year: request.year,
        status: 'available',
        dailyRate: request.dailyRate,
        mileage: 0,
        registrationExpiry: DateTime.now().add(Duration(days: 365)),
        insuranceExpiry: DateTime.now().add(Duration(days: 365)),
        lastMaintenanceDate: DateTime.now(),
        nextMaintenanceDate: DateTime.now().add(Duration(days: 60)),
        transmissionType: request.transmissionType,
        seatCount: request.seatCount,
        fuelType: request.fuelType,
        rentalHistory: [],
      );

      _vehicles.insert(0, newVehicle);
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

  Future<bool> updateVehicleStatus(String vehicleId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        final vehicle = _vehicles[index];
        _vehicles[index] = Vehicle(
          id: vehicle.id,
          model: vehicle.model,
          make: vehicle.make,
          licensePlate: vehicle.licensePlate,
          color: vehicle.color,
          year: vehicle.year,
          status: newStatus,
          dailyRate: vehicle.dailyRate,
          mileage: vehicle.mileage,
          registrationExpiry: vehicle.registrationExpiry,
          insuranceExpiry: vehicle.insuranceExpiry,
          lastMaintenanceDate: vehicle.lastMaintenanceDate,
          nextMaintenanceDate: vehicle.nextMaintenanceDate,
          transmissionType: vehicle.transmissionType,
          seatCount: vehicle.seatCount,
          fuelType: vehicle.fuelType,
          rentalHistory: vehicle.rentalHistory,
        );
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Vehicle not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleMaintenance(MaintenanceRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _vehicles.indexWhere((v) => v.id == request.vehicleId);
      if (index != -1) {
        final vehicle = _vehicles[index];
        _vehicles[index] = Vehicle(
          id: vehicle.id,
          model: vehicle.model,
          make: vehicle.make,
          licensePlate: vehicle.licensePlate,
          color: vehicle.color,
          year: vehicle.year,
          status: 'maintenance',
          dailyRate: vehicle.dailyRate,
          mileage: vehicle.mileage,
          registrationExpiry: vehicle.registrationExpiry,
          insuranceExpiry: vehicle.insuranceExpiry,
          lastMaintenanceDate: DateTime.now(),
          nextMaintenanceDate: request.scheduledDate,
          transmissionType: vehicle.transmissionType,
          seatCount: vehicle.seatCount,
          fuelType: vehicle.fuelType,
          rentalHistory: vehicle.rentalHistory,
        );
        _maintenanceHistory.add(vehicle);
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Vehicle not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeMaintenance(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        await updateVehicleStatus(vehicleId, 'available');
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Vehicle not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMileage(String vehicleId, int newMileage) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 300));

      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        final vehicle = _vehicles[index];
        _vehicles[index] = Vehicle(
          id: vehicle.id,
          model: vehicle.model,
          make: vehicle.make,
          licensePlate: vehicle.licensePlate,
          color: vehicle.color,
          year: vehicle.year,
          status: vehicle.status,
          dailyRate: vehicle.dailyRate,
          mileage: newMileage,
          registrationExpiry: vehicle.registrationExpiry,
          insuranceExpiry: vehicle.insuranceExpiry,
          lastMaintenanceDate: vehicle.lastMaintenanceDate,
          nextMaintenanceDate: vehicle.nextMaintenanceDate,
          transmissionType: vehicle.transmissionType,
          seatCount: vehicle.seatCount,
          fuelType: vehicle.fuelType,
          rentalHistory: vehicle.rentalHistory,
        );
        _error = null;
        notifyListeners();
        return true;
      }

      throw Exception('Vehicle not found');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get vehicle by ID
  Vehicle? getVehicleById(String vehicleId) {
    try {
      return _vehicles.firstWhere((v) => v.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  // Get vehicles needing maintenance soon
  List<Vehicle> getVehiclesNeedingMaintenance() {
    return _vehicles
        .where((v) => v.nextMaintenanceDate.isBefore(DateTime.now().add(Duration(days: 14))))
        .toList();
  }

  // Get vehicles with expiring registration
  List<Vehicle> getVehiclesExpiringRegistration() {
    return _vehicles
        .where((v) => v.registrationExpiry.isBefore(DateTime.now().add(Duration(days: 30))))
        .toList();
  }

  // Get vehicles with expiring insurance
  List<Vehicle> getVehiclesExpiringInsurance() {
    return _vehicles
        .where((v) => v.insuranceExpiry.isBefore(DateTime.now().add(Duration(days: 30))))
        .toList();
  }

  Future<void> refreshVehicles() async {
    await _loadVehicles();
  }
}
