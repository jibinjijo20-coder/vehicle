import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'user_manager.dart';
import 'trip_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _newUserWrapper = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await userManager.fetchUsers();
    setState(() => _isLoading = false);
  }

  Future<void> _addUser() async {
    final name = _newUserWrapper.text.trim();
    if (name.isNotEmpty) {
      setState(() => _isLoading = true);
      await userManager.addUser(name);
      _newUserWrapper.clear();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeUser(String name) async {
    setState(() => _isLoading = true);
    await userManager.removeUser(name);
    setState(() => _isLoading = false);
  }

  Future<void> _addTrip({
    required String driverName,
    required String consignee,
    required String containerNumber,
    required String vehicleNumber,
    String? destination,
    double? startingKm,
  }) async {
    try {
      final tripData = {
        'driver_name': driverName,
        'consignee': consignee,
        'container_number': containerNumber,
        'vehicle_number': vehicleNumber,
        'destination': destination,
        'starting_km': startingKm,
      };

      await _supabase.from('trips').insert(tripData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JOURNEY STARTED SUCCESSFULLY'), backgroundColor: AppTheme.accentSuccess),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentWarning),
        );
      }
    }
  }

  void _showDriverOptions(String driverName) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('OPTIONS: ${driverName.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showAddTripDialog(driverName);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.add_road, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 16),
                const Text('START NEW JOURNEY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripManagementScreen(filterDriver: driverName, readOnly: true),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.history, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 16),
                const Text('VIEW TRIP HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddTripDialog(String driverName) {
    final consigneeController = TextEditingController();
    final containerController = TextEditingController();
    final vehicleController = TextEditingController();
    final destinationController = TextEditingController();
    final kmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('START TRIP: $driverName', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: consigneeController,
                decoration: AppTheme.inputDecoration('Consignee', icon: Icons.business),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: containerController,
                decoration: AppTheme.inputDecoration('Container Number', icon: Icons.inventory),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: vehicleController,
                decoration: AppTheme.inputDecoration('Vehicle Number', icon: Icons.local_shipping),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: destinationController,
                decoration: AppTheme.inputDecoration('Destination (Optional)', icon: Icons.map),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kmController,
                keyboardType: TextInputType.number,
                decoration: AppTheme.inputDecoration('Starting Odometer (Optional)', icon: Icons.speed),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.accentWarning, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              if (consigneeController.text.isNotEmpty && 
                  containerController.text.isNotEmpty && 
                  vehicleController.text.isNotEmpty) {
                _addTrip(
                  driverName: driverName,
                  consignee: consigneeController.text.trim(),
                  containerNumber: containerController.text.trim(),
                  vehicleNumber: vehicleController.text.trim(),
                  destination: destinationController.text.trim().isNotEmpty ? destinationController.text.trim() : null,
                  startingKm: kmController.text.isNotEmpty ? double.parse(kmController.text) : null,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill Consignee, Container, and Vehicle'), backgroundColor: AppTheme.accentWarning),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('START TRIP'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('DRIVER REGISTRY SYSTEM')),
      body: Column(
        children: [
          _buildAddDriverCard(),
          _buildSearchAndList(),
        ],
      ),
    );
  }

  Widget _buildAddDriverCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ADD AUTHORIZED PERSONNEL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newUserWrapper,
                    decoration: AppTheme.inputDecoration('Full Name of Driver', icon: Icons.person_add),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56, width: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addUser,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: EdgeInsets.zero),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndList() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: AppTheme.inputDecoration('Search Registry', icon: Icons.search),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: () {
              final users = userManager.allowedUsers.where((u) => u.toLowerCase().contains(_searchQuery)).toList();
              if (users.isEmpty && !_isLoading) return _buildEmptyState();
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: users.length,
                itemBuilder: (context, i) => _buildUserCard(users[i]),
              );
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDriverOptions(name),
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(backgroundColor: AppTheme.backgroundLight, child: Icon(Icons.person, color: AppTheme.primaryBlue)),
            title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('TAP FOR OPTIONS (TRIPS / LOGS)', style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.accentWarning), onPressed: () => _removeUser(name)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('NO DRIVERS FOUND', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)));
  }
}
