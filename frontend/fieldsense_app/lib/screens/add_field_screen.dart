// add_field_screen.dart
// Screen for adding a new field with name, coordinates, crop type, acreage.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _acreageController = TextEditingController();
  String? _selectedCrop;

  final List<String> _cropTypes = [
    'Corn',
    'Soybeans',
    'Wheat',
    'Cotton',
    'Sorghum',
    'Hay',
    'Alfalfa',
    'Pasture',
    'Vegetables',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _acreageController.dispose();
    super.dispose();
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
      );
      Navigator.pop(context, field);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Add Field',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF66BB6A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
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
              const Text(
                'Field Information',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildCard([
                _buildTextField(
                  controller: _nameController,
                  label: 'Field Name',
                  hint: 'e.g. North Field',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Field name is required' : null,
                ),
                _buildDivider(),
                _buildDropdown(),
                _buildDivider(),
                _buildTextField(
                  controller: _acreageController,
                  label: 'Acreage',
                  hint: 'e.g. 120.5',
                  keyboardType: TextInputType.number,
                ),
              ]),

              const SizedBox(height: 24),

              const Text(
                'Location',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter the GPS coordinates of your field. You can find these in Google Maps by long-pressing your field location.',
                style: TextStyle(
                  color: Color(0xFF636366),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              _buildCard([
                _buildTextField(
                  controller: _latController,
                  label: 'Latitude',
                  hint: 'e.g. 41.8781',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Latitude is required';
                    final d = double.tryParse(v);
                    if (d == null || d < -90 || d > 90) {
                      return 'Enter a valid latitude (-90 to 90)';
                    }
                    return null;
                  },
                ),
                _buildDivider(),
                _buildTextField(
                  controller: _lonController,
                  label: 'Longitude',
                  hint: 'e.g. -93.0977',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Longitude is required';
                    final d = double.tryParse(v);
                    if (d == null || d < -180 || d > 180) {
                      return 'Enter a valid longitude (-180 to 180)';
                    }
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
                    backgroundColor: const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Field',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 16,
      color: Color(0xFF2C2C2E),
    );
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
        labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
        hintStyle: const TextStyle(color: Color(0xFF48484A)),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: Color(0xFFEF5350)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedCrop,
        dropdownColor: const Color(0xFF1C1C1E),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Crop Type',
          labelStyle: TextStyle(color: Color(0xFF8E8E93)),
          border: InputBorder.none,
        ),
        hint: const Text(
          'Select crop (optional)',
          style: TextStyle(color: Color(0xFF48484A)),
        ),
        items: _cropTypes.map((crop) {
          return DropdownMenuItem(
            value: crop,
            child: Text(crop),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedCrop = val),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: Color(0xFF8E8E93)),
      ),
    );
  }
}
