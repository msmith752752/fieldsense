// add_field_screen.dart
// Add or Edit a field - GPS first, minimal friction.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/field_intelligence.dart';

class AddFieldScreen extends StatefulWidget {
  final SavedField? existingField;
  const AddFieldScreen({super.key, this.existingField});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final TextEditingController _acreageController;
  String? _selectedCrop;
  String? _selectedSoilType;
  DateTime? _plantingDate;
  bool _isLocating = false;
  bool _locationDetected = false;

  bool get _isEditing => widget.existingField != null;

  final List<String> _cropTypes = ['Corn', 'Soybeans', 'Wheat', 'Cotton', 'Sorghum', 'Hay', 'Alfalfa', 'Pasture', 'Vegetables', 'Other'];
  final List<String> _soilTypes = ['Sandy', 'Sandy Loam', 'Loam', 'Clay Loam', 'Clay', 'Silt Loam', 'Other'];

  @override
  void initState() {
    super.initState();
    final f = widget.existingField;
    _nameController = TextEditingController(text: f?.fieldName ?? '');
    _latController = TextEditingController(text: f?.latitude.toString() ?? '');
    _lonController = TextEditingController(text: f?.longitude.toString() ?? '');
    _acreageController = TextEditingController(text: f?.acreage?.toString() ?? '');
    _selectedCrop = f?.cropType;
    _selectedSoilType = f?.soilType;
    if (f?.plantingDate != null) _plantingDate = DateTime.tryParse(f!.plantingDate!);
    if (f != null) _locationDetected = true;

    // Auto-detect location for new fields
    if (!_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _detectLocation());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _acreageController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _showError('Location services are disabled.'); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { _showError('Location permission denied.'); return; }
      }
      if (permission == LocationPermission.deniedForever) { _showError('Location permission denied. Please enable in Settings.'); return; }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
        _locationDetected = true;
        _isLocating = false;
      });
    } catch (e) {
      _showError('Could not detect location. Enter coordinates manually.');
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _showError(String message) {
    setState(() => _isLocating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A2535),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickPlantingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF4A90D9), surface: Color(0xFF1A2535)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _plantingDate = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final field = SavedField(
        fieldName: _nameController.text.trim(),
        latitude: double.parse(_latController.text.trim()),
        longitude: double.parse(_lonController.text.trim()),
        cropType: _selectedCrop,
        acreage: _acreageController.text.isNotEmpty ? double.tryParse(_acreageController.text.trim()) : null,
        soilType: _selectedSoilType,
        plantingDate: _plantingDate != null
            ? '${_plantingDate!.year}-${_plantingDate!.month.toString().padLeft(2, '0')}-${_plantingDate!.day.toString().padLeft(2, '0')}'
            : null,
      );
      Navigator.pop(context, field);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        title: Text(_isEditing ? 'Edit Field' : 'Add Your Field',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Save', style: TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Location first - most important
              _sectionLabel('YOUR LOCATION'),
              const SizedBox(height: 4),
              const Text(
                'We detect your location automatically.',
                style: TextStyle(color: Color(0xFF546E7A), fontSize: 12),
              ),
              const SizedBox(height: 8),

              // GPS status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _locationDetected ? const Color(0xFF5BA05E).withOpacity(0.5) : const Color(0xFF4A90D9).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isLocating)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF4A90D9)))
                    else
                      Icon(
                        _locationDetected ? Icons.check_circle_outline : Icons.my_location_rounded,
                        size: 18,
                        color: _locationDetected ? const Color(0xFF5BA05E) : const Color(0xFF4A90D9),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isLocating ? 'Detecting your location...'
                            : _locationDetected
                                ? 'Location detected — ${_latController.text.isNotEmpty ? "${double.tryParse(_latController.text)?.toStringAsFixed(4) ?? ""}, ${double.tryParse(_lonController.text)?.toStringAsFixed(4) ?? ""}" : ""}'
                                : 'Tap to detect location',
                        style: TextStyle(
                          color: _locationDetected ? const Color(0xFF5BA05E) : const Color(0xFF4A90D9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_locationDetected && !_isLocating)
                      TextButton(
                        onPressed: _detectLocation,
                        child: const Text('Detect', style: TextStyle(color: Color(0xFF4A90D9), fontSize: 13)),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Field info
              _sectionLabel('FIELD DETAILS'),
              const SizedBox(height: 8),
              _buildCard([
                _buildTextField(
                  controller: _nameController,
                  label: 'Field Name',
                  hint: 'e.g. North Field, Back 40',
                  validator: (v) => v == null || v.isEmpty ? 'Give this field a name' : null,
                ),
                _buildDivider(),
                _buildCropDropdown(),
                _buildDivider(),
                _buildSoilDropdown(),
                _buildDivider(),
                _buildTextField(
                  controller: _acreageController,
                  label: 'Acreage (optional)',
                  hint: 'e.g. 120',
                  keyboardType: TextInputType.number,
                ),
              ]),

              const SizedBox(height: 16),

              // Planting date
              _sectionLabel('PLANTING DATE (OPTIONAL)'),
              const SizedBox(height: 4),
              const Text('Helps us track your crop\'s growth stage.', style: TextStyle(color: Color(0xFF546E7A), fontSize: 12)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPlantingDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFF1A2535), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16,
                          color: _plantingDate != null ? const Color(0xFF4A90D9) : const Color(0xFF546E7A)),
                      const SizedBox(width: 10),
                      Text(
                        _plantingDate != null
                            ? '${_plantingDate!.month}/${_plantingDate!.day}/${_plantingDate!.year}'
                            : 'Select planting date',
                        style: TextStyle(color: _plantingDate != null ? Colors.white : const Color(0xFF546E7A), fontSize: 14),
                      ),
                      const Spacer(),
                      if (_plantingDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _plantingDate = null),
                          child: const Icon(Icons.close, size: 16, color: Color(0xFF546E7A)),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Get My Field Intelligence',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A2535), borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 16, color: Color(0xFF1E2D3D));

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF546E7A)),
        hintStyle: const TextStyle(color: Color(0xFF2A3F55)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: Color(0xFFE05C5C)),
      ),
    );
  }

  Widget _buildCropDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedCrop,
        dropdownColor: const Color(0xFF1A2535),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: 'What are you growing?', labelStyle: TextStyle(color: Color(0xFF546E7A)), border: InputBorder.none),
        hint: const Text('Select crop (optional)', style: TextStyle(color: Color(0xFF2A3F55))),
        items: _cropTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() => _selectedCrop = val),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF546E7A)),
      ),
    );
  }

  Widget _buildSoilDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedSoilType,
        dropdownColor: const Color(0xFF1A2535),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(labelText: 'Soil type (optional)', labelStyle: TextStyle(color: Color(0xFF546E7A)), border: InputBorder.none),
        hint: const Text('Select soil type', style: TextStyle(color: Color(0xFF2A3F55))),
        items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (val) => setState(() => _selectedSoilType = val),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF546E7A)),
      ),
    );
  }
}