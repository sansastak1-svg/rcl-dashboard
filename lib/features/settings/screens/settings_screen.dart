import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/auth/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                return Card(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mediumGray),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          child: Text(
                            user?.name[0].toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.gray),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Edit profile coming soon')),
                              );
                            },
                            child: Text('Edit Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),

            // Business Settings
            Text(
              'Business Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingItem(
                      label: 'Business Name',
                      value: 'RCL Rentals Ltd.',
                      onTap: () {},
                    ),
                    SizedBox(height: 12),
                    _SettingItem(
                      label: 'Registration Number',
                      value: 'BN-12345678',
                      onTap: () {},
                    ),
                    SizedBox(height: 12),
                    _SettingItem(
                      label: 'Tax ID',
                      value: 'TX-98765432',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Preferences
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _selectedLanguage,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.gray),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currency',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _selectedCurrency,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.gray),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Notifications
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push Notifications',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Receive alerts and updates',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(
                                () => _notificationsEnabled = value);
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email Notifications',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Daily summary emails',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                        Switch(
                          value: _emailNotifications,
                          onChanged: (value) {
                            setState(
                                () => _emailNotifications = value);
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // About & Support
            Text(
              'About & Support',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Card(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumGray),
                ),
                child: Column(
                  children: [
                    _SettingItem(
                      label: 'App Version',
                      value: '1.0.0',
                      onTap: () {},
                    ),
                    SizedBox(height: 12),
                    _SettingItem(
                      label: 'Help & Support',
                      value: 'Contact us',
                      onTap: () {},
                    ),
                    SizedBox(height: 12),
                    _SettingItem(
                      label: 'Privacy Policy',
                      value: 'Read more',
                      onTap: () {},
                    ),
                    SizedBox(height: 12),
                    _SettingItem(
                      label: 'Terms of Service',
                      value: 'Read more',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            // Logout Button Section
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout().then((_) {
                Navigator.pop(context);
              });
            },
            child: Text('Logout', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray),
        ],
      ),
    );
  }
}
