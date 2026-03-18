import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'admin_login_screen.dart';
import 'vehicle_driver_management_screen.dart';
import 'user_manager.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await userManager.fetchUsers();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      if (userManager.isValidUser(username)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleDriverManagementScreen(),
          ),
        );
      } else {
        setState(() {
          _errorText = 'Access denied. You are not an authorized driver.';
        });
      }
    } else {
      setState(() {
        _errorText = 'Please enter your name to continue';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Blue Navigation Header for Admin Access
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: AppTheme.primaryBlue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                        ).then((_) => _loadUsers());
                      },
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                      label: const Text(
                        'ADMIN LOGIN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Professional Icon
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryBlue, width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping, 
                        color: AppTheme.primaryBlue, size: 80,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Vehicle & Driver Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please identify yourself to access the system.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 50),

                    // White Card for Input
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DRIVER NAME',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _usernameController,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            decoration: AppTheme.inputDecoration('Type your full name here', icon: Icons.person_outline),
                          ),
                          if (_errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(_errorText!, style: const TextStyle(color: AppTheme.accentWarning, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(height: 32),
                          
                          // Large Blue Primary Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'CONTINUE TO DASHBOARD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '© 2026 Fleet Solutions International',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
