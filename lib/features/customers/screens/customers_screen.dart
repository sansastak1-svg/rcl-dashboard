import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/customers/models/customer_models.dart';
import 'package:rcl_dashboard/features/customers/providers/customer_provider.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _summaryCardsController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
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
    _searchController.dispose();
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
        title: Text('Customers', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
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
                MaterialPageRoute(builder: (context) => AddCustomerScreen()),
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
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Total Customers', '${provider.totalCustomers}', Icons.people),
                        _buildStatCard('VIP Members', '${provider.vipCustomers}', Icons.star),
                        _buildStatCard('Outstanding', '\$${provider.totalOutstandingPayment.toStringAsFixed(0)}', Icons.attach_money),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<CustomerProvider>().setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                context.read<CustomerProvider>().setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Consumer<CustomerProvider>(
                    builder: (context, provider, _) {
                      final filters = ['active', 'vip', 'blacklisted'];
                      final labels = ['Active', 'VIP Members', 'Blacklisted'];
                      return Row(
                        children: List.generate(
                          filters.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: _FilterTab(
                              label: labels[index],
                              isSelected: provider.filterType == filters[index],
                              onTap: () {
                                provider.setFilterType(filters[index]);
                                _listController.reset();
                                _listController.forward();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Customers List - Animated
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.customers.isEmpty) {
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
                        Text('Error: ${provider.error}'),
                      ],
                    ),
                  );
                }

                if (provider.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 64, color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          'No customers found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshCustomers(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = provider.customers[index];
                      return _AnimatedCustomerCard(
                        customer: customer,
                        index: index,
                        controller: _listController,
                        itemCount: provider.customers.length,
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

class _AnimatedCustomerCard extends StatefulWidget {
  final Customer customer;
  final int index;
  final AnimationController controller;
  final int itemCount;

  const _AnimatedCustomerCard({
    required this.customer,
    required this.index,
    required this.controller,
    required this.itemCount,
  });

  @override
  State<_AnimatedCustomerCard> createState() => _AnimatedCustomerCardState();
}

class _AnimatedCustomerCardState extends State<_AnimatedCustomerCard> with TickerProviderStateMixin {
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
        child: _CustomerCard(customer: widget.customer),
      ),
    );
  }
}

class _CustomerCard extends StatefulWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard> {
  bool _showActions = false;

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
              context.read<CustomerProvider>().recordPayment(widget.customer.id, amount);
              Navigator.pop(context);
            },
            child: Text('Record'),
          ),
        ],
      ),
    );
  }

  void _showBlacklistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Blacklist Customer?'),
        content: Text('Are you sure you want to blacklist this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CustomerProvider>().blacklistCustomer(widget.customer.id, 'User action');
              Navigator.pop(context);
            },
            child: Text('Blacklist', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLicenseExpired = widget.customer.licenseExpiry.isBefore(DateTime.now());
    final isLicenseExpiringSoon = widget.customer.licenseExpiry.isBefore(DateTime.now().add(Duration(days: 30))) && !isLicenseExpired;
    final hasOutstanding = widget.customer.outstandingPayment > 0;

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
          // Main Customer Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: Text(
                        widget.customer.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customer.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.customer.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 12, color: Colors.grey.shade500),
                              SizedBox(width: 4),
                              Text(
                                widget.customer.phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // License Status Badge
                    if (isLicenseExpired)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'License Expired',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isLicenseExpiringSoon)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warningOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'License Expiring',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warningOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Rentals', '${widget.customer.rentalCount}', Colors.blue),
                    _buildStatColumn('Total Spent', '\$${widget.customer.totalRentals.toStringAsFixed(0)}', Colors.green),
                    if (hasOutstanding)
                      _buildStatColumn('Outstanding', '\$${widget.customer.outstandingPayment.toStringAsFixed(0)}', Colors.red),
                  ],
                ),

                if (hasOutstanding) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_outlined, color: AppColors.errorRed, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Outstanding payment due',
                          style: TextStyle(
                            color: AppColors.errorRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
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
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    onPressed: () {},
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 8),
                if (hasOutstanding)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.payment_outlined,
                      label: 'Pay',
                      onPressed: _showPaymentDialog,
                    ),
                  ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.more_horiz,
                    label: 'More',
                    onPressed: _showBlacklistDialog,
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

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
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
                        ? AppColors.primaryBlue
                        : Colors.grey.shade600,
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
                          ? AppColors.primaryBlue
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
