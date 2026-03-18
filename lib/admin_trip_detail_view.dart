import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'trip_management_screen.dart';

class AdminTripDetailView extends StatefulWidget {
  final Trip trip;
  const AdminTripDetailView({super.key, required this.trip});

  @override
  State<AdminTripDetailView> createState() => _AdminTripDetailViewState();
}

class _AdminTripDetailViewState extends State<AdminTripDetailView> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      final data = await _supabase
          .from('expenses')
          .select()
          .eq('trip_id', widget.trip.id)
          .order('created_at', ascending: false);
      setState(() {
        _expenses = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('JOURNEY LOG DATA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroInfo(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildProofSection(),
            const SizedBox(height: 24),
            _buildExpenseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration().copyWith(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSIGNEE: ${widget.trip.consignee.toUpperCase()}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'DRIVER: ${widget.trip.driverName}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const Divider(color: Colors.white30, height: 24),
          Text(
            'VEHICLE: ${widget.trip.vehicleNumber} | CONT: ${widget.trip.containerNumber}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          if (widget.trip.destination != null)
            Text(
              'DESTINATION: ${widget.trip.destination}',
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatBox('START ODO', '${widget.trip.startingKm ?? "---"} KM')),
        const SizedBox(width: 16),
        Expanded(child: _buildStatBox('END ODO', '${widget.trip.endingKm ?? "---"} KM')),
      ],
    );
  }

  Widget _buildStatBox(String label, String val) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
        ],
      ),
    );
  }

  Widget _buildProofSection() {
    if (widget.trip.startingImageUrl == null && widget.trip.endingImageUrl == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VISUAL VERIFICATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.trip.startingImageUrl != null)
                Expanded(child: _buildImageTile('STARTING PHOTO', widget.trip.startingImageUrl!)),
              if (widget.trip.startingImageUrl != null && widget.trip.endingImageUrl != null) const SizedBox(width: 16),
              if (widget.trip.endingImageUrl != null)
                Expanded(child: _buildImageTile('FINAL PHOTO', widget.trip.endingImageUrl!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(String label, String url) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showFullImage(url),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EXPENSE LOG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        if (_isLoading) const Center(child: CircularProgressIndicator())
        else if (_expenses.isEmpty) const Text('No expenses recorded for this trip.')
        else
          ..._expenses.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['description'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Amount: Tk ${e['amount']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                if (e['bill_image_url'] != null)
                  IconButton(
                    icon: const Icon(Icons.image, color: AppTheme.primaryBlue),
                    onPressed: () => _showFullImage(e['bill_image_url']),
                  ),
              ],
            ),
          )),
      ],
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
          ],
        ),
      ),
    );
  }
}
