class Vehicle {
  final String id;
  final String model;
  final String licensePlate;
  final String color;
  final int year;
  final String status; // 'available', 'rented', 'maintenance'
  final double dailyRate;
  final int mileage;
  final DateTime registrationExpiry;
  final DateTime insuranceExpiry;
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final String? image;
  final String make;
  final String transmissionType; // 'automatic', 'manual'
  final int seatCount;
  final String fuelType;
  final List<String> rentalHistory;

  Vehicle({
    required this.id,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
    required this.status,
    required this.dailyRate,
    required this.mileage,
    required this.registrationExpiry,
    required this.insuranceExpiry,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    this.image,
    required this.make,
    required this.transmissionType,
    required this.seatCount,
    required this.fuelType,
    required this.rentalHistory,
  });

  bool get isRegistrationExpired =>
      registrationExpiry.isBefore(DateTime.now());
  bool get isInsuranceExpired => insuranceExpiry.isBefore(DateTime.now());
  bool get isMaintenanceDue =>
      nextMaintenanceDate.isBefore(DateTime.now());
}

class CreateVehicleRequest {
  final String model;
  final String licensePlate;
  final String color;
  final int year;
  final double dailyRate;
  final String make;
  final String transmissionType;
  final int seatCount;
  final String fuelType;

  CreateVehicleRequest({
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
    required this.dailyRate,
    required this.make,
    required this.transmissionType,
    required this.seatCount,
    required this.fuelType,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'year': year,
      'dailyRate': dailyRate,
      'make': make,
      'transmissionType': transmissionType,
      'seatCount': seatCount,
      'fuelType': fuelType,
    };
  }
}

class MaintenanceRequest {
  final String vehicleId;
  final String type; // 'oil_change', 'tire_rotation', 'inspection', etc.
  final String description;
  final DateTime scheduledDate;
  final double estimatedCost;

  MaintenanceRequest({
    required this.vehicleId,
    required this.type,
    required this.description,
    required this.scheduledDate,
    required this.estimatedCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'type': type,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'estimatedCost': estimatedCost,
    };
  }
}
