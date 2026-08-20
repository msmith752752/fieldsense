// add_field_screen.dart
// Add or Edit a field. Supports GPS, soil type, planting date, and full edit mode.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/field_intelligence.dart';

class AddFieldScreen extends StatefulWidget {
  final SavedField? existingField; // if provided, we're in edit mode

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

  final List<String> _cropTypes = [
    'Corn', 'Soybeans', 'Wheat', 'Cotton', 'Sorghum',
    'Hay', 'Alfalfa', 'Pasture', 'Vegetables', 'Other',
  ];

  final List<String> _soilTypes = [
    'Sandy', 'Sandy Loam', 'Loam', 'Clay Loam', 'Clay', 'Silt Loam', 'Other',
  ];

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
    if (f?.plantingDate != null) {
      _plantingDate = DateTime.tryParse(f!.plantingDate!);
    }
    if (f != null) _locationDetected = true;
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
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable them in Settings.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission permanently denied. Please enable it in Settings.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lonController.text = position.longitude.toStringAsFixed(6);
        _locationDetected = true;
        _isLocating = false;
      });
    } catch (e) {
      _showError('Could not determine location. Please enter coordinates manually.');
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90D9),
              surface: Color(0xFF1A2535),
            ),
          ),
          child: child!,
        );
      },
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
        acreage: _acreageController.text.isNotEmpty
            ? double.tryParse(_acreageController.text.trim())
            : null,
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
        title: Text(
          _isEditing ? 'Edit Field' : 'Add Field',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.w600, fontSize: 16)),
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
              // Field Information
              _sectionLabel('FIELD INFORMATION'),
              const SizedBox(height: 8),
              _buildCard([
                _buildTextField(
                  controller: _nameController,
                  label: 'Field Name',
                  hint: 'e.g. North Field',
                  validator: (v) => v == null || v.isEmpty ? 'Field name is required' : null,
                ),
                _buildDivider(),
                _buildCropDropdown(),
                _buildDivider(),
                _buildSoilDropdown(),
                _buildDivider(),
                _buildTextField(
                  controller: _acreageController,
                  label: 'Acreage',
                  hint: 'e.g. 120.5',
                  keyboardType: TextInputType.number,
                ),
              ]),

              const SizedBox(height: 16),

              // Planting Date
              _sectionLabel('PLANTING DATE'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPlantingDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2535),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: _plantingDate != null
                            ? const Color(0xFF4A90D9)
                            : const Color(0xFF546E7A),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _plantingDate != null
                            ? '${_plantingDate!.month}/${_plantingDate!.day}/${_plantingDate!.year}'
                            : 'Select planting date (optional)',
                        style: TextStyle(
                          color: _plantingDate != null
                              ? Colors.white
                              : const Color(0xFF546E7A),
                          fontSize: 14,
                        ),
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

              const SizedBox(height: 24),

              // Location
              _sectionLabel('LOCATION'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isLocating ? null : _detectLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2535),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _locationDetected
                          ? const Color(0xFF5BA05E).withOpacity(0.5)
                          : const Color(0xFF4A90D9).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLocating)
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF4A90D9)),
                        )
                      else
                        Icon(
                          _locationDetected ? Icons.check_circle_outline : Icons.my_location_rounded,
                          size: 18,
                          color: _locationDetected ? const Color(0xFF5BA05E) : const Color(0xFF4A90D9),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        _isLocating ? 'Detecting location...'
                            : _locationDetected ? 'Location detected'
                            : 'Use my current location',
                        style: TextStyle(
                          color: _locationDetected ? const Color(0xFF5BA05E) : const Color(0xFF4A90D9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text('Or enter coordinates manually',
                  style: TextStyle(color: Color(0xFF546E7A), fontSize: 12)),
              const SizedBox(height: 8),

              _buildCard([
                _buildTextField(
                  controller: _latController,
                  label: 'Latitude',
                  hint: 'e.g. 41.8781',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Latitude is required';
                    final d = double.tryParse(v);
                    if (d == null || d < -90 || d > 90) return 'Enter a valid latitude (-90 to 90)';
                    return null;
                  },
                ),
                _buildDivider(),
                _buildTextField(
                  controller: _lonController,
                  label: 'Longitude',
                  hint: 'e.g. -93.0977',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Longitude is required';
                    final d = double.tryParse(v);
                    if (d == null || d < -180 || d > 180) return 'Enter a valid longitude (-180 to 180)';
                    return null;
                  },
                ),
              ]),

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
                    _isEditing ? 'Save Changes' : 'Add Field',
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
    return Text(text,
        style: const TextStyle(
            color: Color(0xFF546E7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A2535), borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, color: Color(0xFF1E2D3D));
  }

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
        decoration: const InputDecoration(
          labelText: 'Crop Type',
          labelStyle: TextStyle(color: Color(0xFF546E7A)),
          border: InputBorder.none,
        ),
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
        decoration: const InputDecoration(
          labelText: 'Soil Type',
          labelStyle: TextStyle(color: Color(0xFF546E7A)),
          border: InputBorder.none,
        ),
        hint: const Text('Select soil type (optional)', style: TextStyle(color: Color(0xFF2A3F55))),
        items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (val) => setState(() => _selectedSoilType = val),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF546E7A)),
      ),
    );
  }
}
