import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/bookings/models/booking_models.dart';
import 'package:rcl_dashboard/features/bookings/providers/booking_provider.dart';
import 'package:rcl_dashboard/features/bookings/screens/add_booking_screen.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with TickerProviderStateMixin {
  late AnimationController _summaryCardsController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Summary cards animation
    _summaryCardsController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _summaryCardsController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _summaryCardsController, curve: Curves.easeOut),
    );
    
    // List animation
    _listController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _summaryCardsController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _summaryCardsController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        title: Text('Bookings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookingScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with Stats - Animated
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                color: AppColors.darkNavy,
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Total Bookings', '${provider.totalActiveBookings}', Icons.assignment),
                        _buildStatCard('Revenue', '\$${provider.totalRevenue.toStringAsFixed(0)}', Icons.attach_money),
                        _buildStatCard('Pending', '\$${provider.pendingRevenue.toStringAsFixed(0)}', Icons.schedule),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Search and Filter Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Filter Tabs
                Consumer<BookingProvider>(
                  builder: (context, provider, _) {
                    final filters = ['active', 'upcoming', 'completed', 'cancelled', 'archived'];
                    final labels = ['Active', 'Upcoming', 'Completed', 'Cancelled', 'Archive'];
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          filters.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: _FilterTab(
                              label: labels[index],
                              isSelected: provider.filterTab == filters[index],
                              onTap: () {
                                provider.setFilterTab(filters[index]);
                                _listController.reset();
                                _listController.forward();
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bookings List - Animated
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.bookings.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                        SizedBox(height: 16),
                        Text('Error: ${provider.error}', textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                if (provider.bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          'No ${provider.filterTab} bookings',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshBookings(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: provider.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = provider.bookings[index];
                      return _AnimatedBookingCard(
                        booking: booking,
                        index: index,
                        controller: _listController,
                        itemCount: provider.bookings.length,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBookingCard extends StatefulWidget {
  final Booking booking;
  final int index;
  final AnimationController controller;
  final int itemCount;

  const _AnimatedBookingCard({
    required this.booking,
    required this.index,
    required this.controller,
    required this.itemCount,
  });

  @override
  State<_AnimatedBookingCard> createState() => _AnimatedBookingCardState();
}

class _AnimatedBookingCardState extends State<_AnimatedBookingCard> with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    final delay = (widget.index * 50).toDouble();
    final staggeredController = widget.controller;
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: staggeredController,
        curve: Interval(
          (delay / 600).clamp(0, 1),
          ((delay + 200) / 600).clamp(0, 1),
          curve: Curves.easeOut,
        ),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: staggeredController,
        curve: Interval(
          (delay / 600).clamp(0, 1),
          ((delay + 200) / 600).clamp(0, 1),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _BookingCard(booking: widget.booking),
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _showActions = false;

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.successGreen;
      case 'active':
        return AppColors.primaryBlue;
      case 'upcoming':
        return AppColors.warningOrange;
      case 'cancelled':
        return AppColors.errorRed;
      case 'pending':
        return AppColors.warningOrange;
      default:
        return Colors.grey;
    }
  }

  void _showPaymentDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter payment amount',
            prefixText: '\$',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              context.read<BookingProvider>().payBooking(widget.booking.id, amount);
              Navigator.pop(context);
            },
            child: Text('Record'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Booking?'),
        content: Text('Mark this booking as completed and move to archive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookingProvider>().completeBooking(widget.booking.id);
              Navigator.pop(context);
            },
            child: Text('Complete', style: TextStyle(color: AppColors.successGreen)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking?'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookingProvider>().cancelBooking(widget.booking.id);
              Navigator.pop(context);
            },
            child: Text('Cancel Booking', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.booking.status);
    final paymentPercentage = widget.booking.totalPrice > 0
        ? (widget.booking.paidAmount / widget.booking.totalPrice * 100).clamp(0, 100)
        : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(
                        Icons.calendar_today,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.booking.vehicleModel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.booking.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.booking.customerName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM dd').format(widget.booking.startDate)} - ${DateFormat('MMM dd').format(widget.booking.endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Payment Progress
                if (widget.booking.status != 'cancelled')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${paymentPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: paymentPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(statusColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${widget.booking.paidAmount.toStringAsFixed(2)} / \$${widget.booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),

                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn('Duration', '${widget.booking.endDate.difference(widget.booking.startDate).inDays} days'),
                    _buildDetailColumn('Daily Rate', '\$${widget.booking.dailyRate.toStringAsFixed(0)}'),
                    _buildDetailColumn('Total', '\$${widget.booking.totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          if (widget.booking.status != 'archived' && widget.booking.status != 'cancelled')
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (widget.booking.paidAmount < widget.booking.totalPrice)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.payment_outlined,
                        label: 'Pay',
                        onPressed: _showPaymentDialog,
                      ),
                    ),
                  if (widget.booking.paidAmount < widget.booking.totalPrice && widget.booking.status == 'active')
                    SizedBox(width: 8),
                  if (widget.booking.status == 'active' || widget.booking.status == 'completed')
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.check_circle_outline,
                        label: 'Complete',
                        onPressed: _showCompleteDialog,
                        isPrimary: true,
                      ),
                    ),
                  if ((widget.booking.status == 'active' || widget.booking.status == 'upcoming') && widget.booking.paidAmount < widget.booking.totalPrice)
                    SizedBox(width: 8),
                  if (widget.booking.status == 'active' || widget.booking.status == 'upcoming')
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.close_outlined,
                        label: 'Cancel',
                        onPressed: _showCancelDialog,
                        isDanger: true,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDanger
                    ? AppColors.errorRed
                    : isPrimary
                        ? AppColors.successGreen
                        : AppColors.primaryBlue,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDanger
                      ? AppColors.errorRed
                      : isPrimary
                          ? AppColors.successGreen
                          : AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

