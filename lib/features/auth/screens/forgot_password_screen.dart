import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rcl_dashboard/core/constants/app_colors.dart';
import 'package:rcl_dashboard/features/auth/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late TextEditingController _emailController;
  int _step = 1; // 1: Email, 2: Reset Code, 3: New Password

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    final authProvider = context.read<AuthProvider>();
    authProvider.forgotPassword(email: _emailController.text.trim()).then((success) {
      if (success && mounted) {
        setState(() => _step = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to ${_emailController.text}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Reset Password'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Text(
                _step == 1
                    ? 'Enter your email'
                    : _step == 2
                        ? 'Check your email'
                        : 'Create new password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 12),
              Text(
                _step == 1
                    ? 'We\'ll send you a link to reset your password'
                    : _step == 2
                        ? 'We sent a reset link to ${_emailController.text}'
                        : 'Enter a new password for your account',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.gray),
              ),
              SizedBox(height: 48),
              if (_step == 1) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.primaryBlue),
                  ),
                ),
                SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _sendResetLink,
                        child: authProvider.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text('Send Reset Link'),
                      ),
                    );
                  },
                ),
              ] else if (_step == 2) ...[
                // Check email step
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.mark_email_read_outlined,
                          size: 48, color: AppColors.primaryBlue),
                      SizedBox(height: 16),
                      Text(
                        'Check your email for a reset link.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _step = 3),
                    child: Text('I\'ve entered the code'),
                  ),
                ),
              ] else if (_step == 3) ...[
                // New password step
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password reset successful')),
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Reset Password'),
                  ),
                ),
              ],
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Remember password? ',
                      style: Theme.of(context).textTheme.bodySmall),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to login',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
