class Booking {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyRate;
  final double totalPrice;
  final double paidAmount;
  final String status; // 'active', 'upcoming', 'completed', 'cancelled'
  final String paymentStatus; // 'pending', 'partial', 'completed'
  final String notes;
  final DateTime createdAt;
  final bool isArchived;

  Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.startDate,
    required this.endDate,
    required this.dailyRate,
    required this.totalPrice,
    required this.paidAmount,
    required this.status,
    required this.paymentStatus,
    required this.notes,
    required this.createdAt,
    this.isArchived = false,
  });

  int get rentalDays => endDate.difference(startDate).inDays + 1;
  double get remainingPayment => totalPrice - paidAmount;
  bool get isOverdue => endDate.isBefore(DateTime.now()) && status == 'active';
  bool get isActive => status == 'active' && startDate.isBefore(DateTime.now());
  bool get isUpcoming => status == 'upcoming' && startDate.isAfter(DateTime.now());
  bool get isEnded => endDate.isBefore(DateTime.now());

  // Copy with for creating modified versions
  Booking copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? vehicleId,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    DateTime? startDate,
    DateTime? endDate,
    double? dailyRate,
    double? totalPrice,
    double? paidAmount,
    String? status,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyRate: dailyRate ?? this.dailyRate,
      totalPrice: totalPrice ?? this.totalPrice,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class CreateBookingRequest {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyRate;
  final double totalPrice;
  final String notes;

  CreateBookingRequest({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.startDate,
    required this.endDate,
    required this.dailyRate,
    required this.totalPrice,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehicleId': vehicleId,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'dailyRate': dailyRate,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
}

class UpdateBookingRequest {
  final String id;
  final DateTime? endDate;
  final String? status;
  final double? paidAmount;
  final String? notes;
  final bool? isArchived;

  UpdateBookingRequest({
    required this.id,
    this.endDate,
    this.status,
    this.paidAmount,
    this.notes,
    this.isArchived,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (endDate != null) 'endDate': endDate?.toIso8601String(),
      if (status != null) 'status': status,
      if (paidAmount != null) 'paidAmount': paidAmount,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'isArchived': isArchived,
    };
  }
}
