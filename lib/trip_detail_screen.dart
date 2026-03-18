import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'trip_management_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TextEditingController _endingKmController = TextEditingController();
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  
  File? _billImage;
  File? _odoImage;
  final ImagePicker _picker = ImagePicker();
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _expenses = [];
  bool _isActionLoading = false;
  
  final List<String> _expenseOptions = [
    'Weightment',
    'Tyrework',
    'Tea Cash',
    'Cleaning Charge',
    'Others'
  ];
  String? _selectedExpenseType;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      final data = await _supabase.from('expenses').select().eq('trip_id', widget.trip.id).order('created_at', ascending: false);
      setState(() => _expenses = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<String?> _uploadImage(File file, String folder) async {
    final fileName = '${folder}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'trips/$fileName';
    await _supabase.storage.from('images_vmanagement').upload(path, file);
    return _supabase.storage.from('images_vmanagement').getPublicUrl(path);
  }

  Future<void> _updateStartingData(double km, String? destination, File? photo, [void Function(void Function())? setDialogState]) async {
    setState(() => _isActionLoading = true);
    if (setDialogState != null) setDialogState(() {});
    
    try {
      debugPrint('Starting update for trip: ${widget.trip.id}');
      String? imageUrl;
      if (photo != null) {
        debugPrint('Uploading start image...');
        imageUrl = await _uploadImage(photo, 'start');
      }

      final Map<String, dynamic> updates = {'starting_km': km};
      if (destination != null) updates['destination'] = destination;
      if (imageUrl != null) updates['starting_image_url'] = imageUrl;

      debugPrint('Sending updates to Supabase: $updates');
      await _supabase.from('trips').update(updates).eq('id', widget.trip.id);
      
      setState(() {
        widget.trip.startingKm = km;
        if (destination != null) widget.trip.destination = destination;
        if (imageUrl != null) widget.trip.startingImageUrl = imageUrl;
        _isActionLoading = false;
      });
      if (setDialogState != null) setDialogState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('TRIP DATA ADDED'), backgroundColor: AppTheme.accentSuccess));
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('CATCH Error during update starting data: $e');
      setState(() => _isActionLoading = false);
      if (setDialogState != null) setDialogState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FAILED TO SAVE: $e'), backgroundColor: AppTheme.accentWarning));
      }
    }
  }

  Future<void> _completeTrip(double km, File? photo) async {
    setState(() => _isActionLoading = true);
    try {
      debugPrint('Completing trip: ${widget.trip.id}');
      String? imageUrl;
      if (photo != null) {
        debugPrint('Uploading end image...');
        imageUrl = await _uploadImage(photo, 'end');
      }

      await _supabase.from('trips').update({
        'ending_km': km,
        'ending_image_url': imageUrl,
        'is_completed': true,
      }).eq('id', widget.trip.id);

      setState(() {
        widget.trip.endingKm = km;
        widget.trip.endingImageUrl = imageUrl;
        widget.trip.isCompleted = true;
        _isActionLoading = false;
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('CATCH Error during complete trip: $e');
      setState(() => _isActionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FAILED TO COMPLETE: $e'), backgroundColor: AppTheme.accentWarning));
      }
    }
  }

  void _showStartTripDialog() {
    final kmC = TextEditingController();
    final destC = TextEditingController(text: widget.trip.destination);
    setState(() => _odoImage = null);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('INITIALIZE TRIP DATA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.trip.destination == null || widget.trip.destination!.isEmpty)
                  TextField(controller: destC, decoration: AppTheme.inputDecoration('Set Destination', icon: Icons.map)),
                const SizedBox(height: 16),
                TextField(controller: kmC, keyboardType: TextInputType.number, decoration: AppTheme.inputDecoration('Starting KM', icon: Icons.speed)),
                const SizedBox(height: 16),
                _buildImagePickerButton(() async {
                  final xf = await _picker.pickImage(source: ImageSource.camera);
                  if (xf != null) {
                    setState(() => _odoImage = File(xf.path));
                    setDialogState(() {});
                  }
                }, _odoImage != null),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: _isActionLoading ? null : () {
                if (kmC.text.isNotEmpty) {
                  _updateStartingData(
                    double.parse(kmC.text), 
                    destC.text.trim().isNotEmpty ? destC.text.trim() : null, 
                    _odoImage,
                    setDialogState
                  ).then((_) {
                    setState(() {});
                  });
                }
              },
              child: _isActionLoading 
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('SAVE DATA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton(VoidCallback onTap, bool hasImage) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasImage ? Icons.check_circle : Icons.camera_alt, color: hasImage ? AppTheme.accentSuccess : AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(hasImage ? 'PHOTO ATTACHED' : 'SNAP PHOTO', style: TextStyle(fontWeight: FontWeight.bold, color: hasImage ? AppTheme.accentSuccess : AppTheme.primaryBlue)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('JOURNEY DETAILS')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildHeroInfo(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                if (!widget.trip.isCompleted) _buildCompletionCard(),
                const SizedBox(height: 24),
                _buildExpenseSection(),
                const SizedBox(height: 24),
                _buildExistingExpenses(),
              ],
            ),
          ),
          if (_isActionLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildHeroInfo() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration().copyWith(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONSIGNEE: ${widget.trip.consignee.toUpperCase()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text('DRIVER: ${widget.trip.driverName}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const Divider(color: Colors.white30),
          if (widget.trip.destination != null && widget.trip.destination!.isNotEmpty)
            Text('TO: ${widget.trip.destination}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          else
            const Text('DESTINATION: NOT SET', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildMileageCard('START ODO', widget.trip.startingKm, widget.trip.startingImageUrl, _showStartTripDialog)),
        const SizedBox(width: 16),
        Expanded(child: _buildMileageCard('END ODO', widget.trip.endingKm, widget.trip.endingImageUrl, null)),
      ],
    );
  }

  Widget _buildMileageCard(String label, double? val, String? img, VoidCallback? onTap) {
    return InkWell(
      onTap: img != null ? () => _showImagePreview(img) : (widget.trip.isCompleted ? null : onTap),
      child: Container(
        padding: const EdgeInsets.all(20), decoration: AppTheme.cardDecoration(),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            Text(val != null ? '$val KM' : 'SET NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: val == null ? AppTheme.accentWarning : AppTheme.textMain)),
            if (img != null) const Icon(Icons.photo_library, size: 16, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(24), decoration: AppTheme.cardDecoration().copyWith(border: Border.all(color: AppTheme.accentSuccess, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FINALIZE JOURNEY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(controller: _endingKmController, keyboardType: TextInputType.number, decoration: AppTheme.inputDecoration('Final Odometer Reading', icon: Icons.flag)),
          const SizedBox(height: 16),
          _buildImagePickerButton(() async {
            final xf = await _picker.pickImage(source: ImageSource.camera);
            if (xf != null) setState(() => _odoImage = File(xf.path));
          }, _odoImage != null),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => _completeTrip(double.parse(_endingKmController.text), _odoImage), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentSuccess), child: const Text('SUBMIT COMPLETION'))),
        ],
      ),
    );
  }

  void _showImagePreview(String url) {
    showDialog(context: context, builder: (context) => Dialog(child: Column(mainAxisSize: MainAxisSize.min, children: [Image.network(url, loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child : const CircularProgressIndicator()), TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE'))])));
  }

  Widget _buildExpenseSection() {
    return Container(
      padding: const EdgeInsets.all(24), decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOG EXPERIENCE / EXPENDITURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedExpenseType,
            decoration: AppTheme.inputDecoration('Select Expense Type', icon: Icons.category),
            items: _expenseOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: (v) => setState(() => _selectedExpenseType = v),
          ),
          if (_selectedExpenseType == 'Others') ...[
            const SizedBox(height: 12),
            TextField(controller: _expenseNameController, decoration: AppTheme.inputDecoration('Custom Expense Name', icon: Icons.description)),
          ],
          const SizedBox(height: 12),
          TextField(controller: _expenseAmountController, keyboardType: TextInputType.number, decoration: AppTheme.inputDecoration('Amount (Tk)', icon: Icons.attach_money)),
          const SizedBox(height: 16),
          _buildImagePickerButton(() async {
            final xf = await _picker.pickImage(source: ImageSource.camera);
            if (xf != null) setState(() => _billImage = File(xf.path));
          }, _billImage != null),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _addExpenseInternal, child: const Text('SUBMIT EXPENSE')))
        ],
      ),
    );
  }

  Future<void> _addExpenseInternal() async {
    final String description = _selectedExpenseType == 'Others' 
        ? _expenseNameController.text.trim() 
        : (_selectedExpenseType ?? '');

    if (description.isEmpty || _expenseAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a type and enter amount'), backgroundColor: AppTheme.accentWarning));
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      String? url;
      if (_billImage != null) url = await _uploadImage(_billImage!, 'bill');
      
      await _supabase.from('expenses').insert({
        'trip_id': widget.trip.id, 
        'description': description, 
        'amount': double.parse(_expenseAmountController.text), 
        'bill_image_url': url
      });
      
      _expenseNameController.clear();
      _expenseAmountController.clear();
      setState(() {
        _billImage = null;
        _selectedExpenseType = null;
      });
      _fetchExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('EXPENSE LOGGED SUCCESSFULLY'), backgroundColor: AppTheme.accentSuccess));
      }
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  Widget _buildExistingExpenses() {
    if (_expenses.isEmpty) return const SizedBox.shrink();
    return Column(children: _expenses.map((e) => ListTile(title: Text(e['description']), trailing: Text('Tk ${e['amount']}'))).toList());
  }
}
