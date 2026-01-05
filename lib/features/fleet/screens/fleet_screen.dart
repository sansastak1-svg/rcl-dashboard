import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/fleet/models/vehicle_models.dart';
import 'package:rcl_dashboard/features/fleet/providers/fleet_provider.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({Key? key}) : super(key: key);

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> with TickerProviderStateMixin {
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
        title: Text('Fleet Management', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
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
              // Navigate to add vehicle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add Vehicle feature coming soon')),
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
                child: Consumer<FleetProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Total Vehicles', '${provider.totalVehicles}', Icons.directions_car),
                        _buildStatCard('Available', '${provider.availableVehicles}', Icons.check_circle),
                        _buildStatCard('Fleet Value', '\$${(provider.totalFleetValue / 1000).toStringAsFixed(0)}K', Icons.attach_money),
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
                      context.read<FleetProvider>().setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by model, plate, or make',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                context.read<FleetProvider>().setSearchQuery('');
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
                Consumer<FleetProvider>(
                  builder: (context, provider, _) {
                    final filters = ['all', 'available', 'rented', 'maintenance'];
                    final labels = ['All', 'Available', 'Rented', 'Maintenance'];
                    final colors = [
                      Colors.grey,
                      AppColors.successGreen,
                      AppColors.primaryBlue,
                      AppColors.warningOrange,
                    ];
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          filters.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: _FilterTab(
                              label: labels[index],
                              isSelected: provider.filterStatus == filters[index],
                              color: colors[index],
                              onTap: () {
                                provider.setFilterStatus(filters[index]);
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

          // Vehicles List - Animated
          Expanded(
            child: Consumer<FleetProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.vehicles.isEmpty) {
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

                if (provider.vehicles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                        SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshVehicles(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: provider.vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return _AnimatedVehicleCard(
                        vehicle: vehicle,
                        index: index,
                        controller: _listController,
                        itemCount: provider.vehicles.length,
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
  final Color color;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.color,
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
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
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

class _AnimatedVehicleCard extends StatefulWidget {
  final Vehicle vehicle;
  final int index;
  final AnimationController controller;
  final int itemCount;

  const _AnimatedVehicleCard({
    required this.vehicle,
    required this.index,
    required this.controller,
    required this.itemCount,
  });

  @override
  State<_AnimatedVehicleCard> createState() => _AnimatedVehicleCardState();
}

class _AnimatedVehicleCardState extends State<_AnimatedVehicleCard> with TickerProviderStateMixin {
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
        child: _VehicleCard(vehicle: widget.vehicle),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  Color _getStatusColor() {
    switch (vehicle.status.toLowerCase()) {
      case 'available':
        return AppColors.successGreen;
      case 'rented':
        return AppColors.primaryBlue;
      case 'maintenance':
        return AppColors.warningOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

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
                        Icons.directions_car,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.model,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            vehicle.licensePlate,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                              SizedBox(width: 4),
                              Text(
                                vehicle.make,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Vehicle Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailColumn('Daily Rate', '\$${vehicle.dailyRate.toStringAsFixed(0)}/day'),
                    _buildDetailColumn('Year', '${vehicle.year}'),
                    _buildDetailColumn('Mileage', '${vehicle.mileage} mi'),
                  ],
                ),

                if (vehicle.status.toLowerCase() == 'maintenance') ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_outlined, color: AppColors.warningOrange, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'In maintenance',
                          style: TextStyle(
                            color: AppColors.warningOrange,
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
                    icon: Icons.info_outlined,
                    label: 'Details',
                    onPressed: () {},
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 8),
                if (vehicle.status.toLowerCase() == 'available')
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onPressed: () {},
                    ),
                  ),
                if (vehicle.status.toLowerCase() == 'maintenance')
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.check_circle_outline,
                      label: 'Complete',
                      onPressed: () {},
                    ),
                  ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Manage',
                    onPressed: () {},
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
                color: isPrimary ? AppColors.primaryBlue : Colors.grey.shade600,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppColors.primaryBlue : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
