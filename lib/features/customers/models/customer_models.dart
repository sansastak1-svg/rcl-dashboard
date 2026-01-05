class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String? avatar;
  final DateTime createdAt;
  final double totalRentals;
  final int rentalCount;
  final double outstandingPayment;
  final String idProof; // URL or path
  final String licenseProof;
  final List<String> rentalHistory;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.avatar,
    required this.createdAt,
    required this.totalRentals,
    required this.rentalCount,
    required this.outstandingPayment,
    required this.idProof,
    required this.licenseProof,
    required this.rentalHistory,
  });

  bool get isLicenseExpired => licenseExpiry.isBefore(DateTime.now());
  bool get isLicenseExpiringSoon =>
      licenseExpiry.isBefore(DateTime.now().add(Duration(days: 30))) &&
      !isLicenseExpired;
}

class CreateCustomerRequest {
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String? idProof;
  final String? licenseProof;

  CreateCustomerRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.idProof,
    this.licenseProof,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry.toIso8601String(),
      if (idProof != null) 'idProof': idProof,
      if (licenseProof != null) 'licenseProof': licenseProof,
    };
  }
}

class UpdateCustomerRequest {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? licenseNumber;
  final DateTime? licenseExpiry;

  UpdateCustomerRequest({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.licenseNumber,
    this.licenseExpiry,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (licenseExpiry != null)
        'licenseExpiry': licenseExpiry?.toIso8601String(),
    };
  }
}
