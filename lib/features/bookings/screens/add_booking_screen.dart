import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/bookings/models/booking_models.dart';
import 'package:rcl_dashboard/features/bookings/providers/booking_provider.dart';
import 'package:rcl_dashboard/features/fleet/models/vehicle_models.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({Key? key}) : super(key: key);

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _notesController;

  String? _selectedVehicleId;
  String? _selectedVehicleModel;
  String? _selectedVehicleColor;
  String? _selectedLicensePlate;
  double? _selectedDailyRate;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Mock vehicles for dropdown
  final List<Map<String, dynamic>> _mockVehicles = [
    {'id': 'VH001', 'model': 'Toyota Camry', 'color': 'Silver', 'plate': 'ABC-123', 'rate': 200.0},
    {'id': 'VH002', 'model': 'Honda Civic', 'color': 'Blue', 'plate': 'XYZ-789', 'rate': 150.0},
    {'id': 'VH004', 'model': 'BMW 3 Series', 'color': 'Black', 'plate': 'BMW-456', 'rate': 250.0},
  ];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _customerPhoneController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_selectedStartDate ?? DateTime.now()) : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  double _calculateTotal() {
    if (_selectedStartDate == null || _selectedEndDate == null || _selectedDailyRate == null) {
      return 0.0;
    }
    int days = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    return days * _selectedDailyRate!;
  }

  void _submitBooking() {
    if (_customerNameController.text.isEmpty ||
        _customerPhoneController.text.isEmpty ||
        _selectedVehicleId == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final request = CreateBookingRequest(
      customerId: 'CUST${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      vehicleId: _selectedVehicleId!,
      vehicleModel: _selectedVehicleModel!,
      vehicleColor: _selectedVehicleColor!,
      licensePlate: _selectedLicensePlate!,
      startDate: _selectedStartDate!,
      endDate: _selectedEndDate!,
      dailyRate: _selectedDailyRate!,
      totalPrice: _calculateTotal(),
      notes: _notesController.text,
    );

    context.read<BookingProvider>().createBooking(request).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<BookingProvider>().error ?? 'Failed to create booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create New Booking'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information Section
            _buildSectionTitle('Customer Information'),
            _buildTextField(
              controller: _customerNameController,
              label: 'Customer Name',
              icon: Icons.person,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _customerPhoneController,
              label: 'Phone Number',
              icon: Icons.phone,
            ),

            SizedBox(height: 24),

            // Vehicle Selection Section
            _buildSectionTitle('Vehicle Selection'),
            _buildVehicleDropdown(),

            if (_selectedVehicleId != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Vehicle',
                        style: Theme.of(context).textTheme.labelSmall),
                    SizedBox(height: 8),
                    Text(_selectedVehicleModel!,
                        style: Theme.of(context).textTheme.titleSmall),
                    Text('$_selectedVehicleColor • $_selectedLicensePlate',
                        style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(height: 8),
                    Text(
                      'Daily Rate: \$${_selectedDailyRate?.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24),

            // Rental Dates Section
            _buildSectionTitle('Rental Dates'),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Start Date',
                    date: _selectedStartDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerField(
                    label: 'End Date',
                    date: _selectedEndDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Price Calculation Section
            if (_selectedStartDate != null && _selectedEndDate != null && _selectedDailyRate != null) ...[
              _buildSectionTitle('Price Summary'),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Daily Rate', '\$${_selectedDailyRate!.toStringAsFixed(2)}'),
                    Divider(height: 16),
                    _buildPriceRow(
                      'Number of Days',
                      '${_selectedEndDate!.difference(_selectedStartDate!).inDays + 1}',
                    ),
                    Divider(height: 16),
                    _buildPriceRow(
                      'Total Amount',
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            // Notes Section
            _buildSectionTitle('Notes (Optional)'),
            _buildTextField(
              controller: _notesController,
              label: 'Special requests or notes',
              icon: Icons.note,
              maxLines: 3,
            ),

            SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Consumer<BookingProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Create Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedVehicleId,
      items: _mockVehicles.map((vehicle) {
        return DropdownMenuItem<String>(
          value: vehicle['id'],
          child: Text('${vehicle['model']} - ${vehicle['plate']}'),
          onTap: () {
            setState(() {
              _selectedVehicleId = vehicle['id'];
              _selectedVehicleModel = vehicle['model'];
              _selectedVehicleColor = vehicle['color'];
              _selectedLicensePlate = vehicle['plate'];
              _selectedDailyRate = vehicle['rate'];
            });
          },
        );
      }).toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: 'Select Vehicle',
        prefixIcon: Icon(Icons.directions_car, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mediumGray),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.mediumGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text(
                  date != null ? dateFormat.format(date) : 'Select date',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primaryBlue : AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
