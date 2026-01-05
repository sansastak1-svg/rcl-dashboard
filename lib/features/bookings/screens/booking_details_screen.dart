import 'package:flutter/material.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/bookings/models/booking_models.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Booking booking;

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking Details'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Edit'),
                onTap: () {
                  // Navigate to edit booking
                },
              ),
              PopupMenuItem(
                child: Text('Extend'),
                onTap: () {
                  // Show extend dialog
                },
              ),
              PopupMenuItem(
                child: Text('Cancel'),
                onTap: () {
                  // Show cancel dialog
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor().withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Status',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    booking.status.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Customer Information
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            _InfoCard(
              icon: Icons.person,
              title: 'Name',
              value: booking.customerName,
            ),
            _InfoCard(
              icon: Icons.phone,
              title: 'Phone',
              value: booking.customerPhone,
            ),

            SizedBox(height: 24),

            // Vehicle Information
            Text(
              'Vehicle Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            _InfoCard(
              icon: Icons.directions_car,
              title: 'Model',
              value: booking.vehicleModel,
            ),
            _InfoCard(
              icon: Icons.badge,
              title: 'License Plate',
              value: booking.licensePlate,
            ),

            SizedBox(height: 24),

            // Rental Period
            Text(
              'Rental Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              dateFormat.format(booking.startDate),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward, color: AppColors.gray),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'End Date',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(height: 8),
                            Text(
                              dateFormat.format(booking.endDate),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: AppColors.gray),
                          SizedBox(width: 8),
                          Text(
                            '${booking.rentalDays} days rental',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Payment Information
            Text(
              'Payment Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PaymentRow(
                      label: 'Total Price',
                      value: '\$${booking.totalPrice.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 12),
                    _PaymentRow(
                      label: 'Paid Amount',
                      value: '\$${booking.paidAmount.toStringAsFixed(2)}',
                      valueColor: AppColors.success,
                    ),
                    SizedBox(height: 12),
                    _PaymentRow(
                      label: 'Remaining',
                      value: '\$${booking.remainingPayment.toStringAsFixed(2)}',
                      isBold: true,
                      valueColor: AppColors.error,
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.paymentStatus.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getPaymentStatusColor(),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Notes
            if (booking.notes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mediumGray),
                      ),
                      child: Text(
                        booking.notes,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment recorded')),
                  );
                },
                child: Text('Record Payment'),
              ),
            ),

            SizedBox(height: 12),

            if (booking.status == 'active')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking extended')),
                    );
                  },
                  child: Text('Extend Rental'),
                ),
              ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
      case 'active':
        return AppColors.primaryGreen;
      case 'upcoming':
        return AppColors.lightBlue;
      case 'completed':
        return AppColors.gray;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }

  Color _getPaymentStatusColor() {
    switch (booking.paymentStatus) {
      case 'completed':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'pending':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mediumGray),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
