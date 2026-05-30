// home_screen.dart
// Clean Dark Sky inspired FieldSense dashboard.

import 'package:flutter/material.dart';
import '../models/field_intelligence.dart';
import '../services/api_service.dart';
import '../services/field_storage_service.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/rainfall_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/moisture_card.dart';
import 'add_field_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SavedField> _fields = [];
  int _selectedFieldIndex = 0;

  FieldIntelligenceResponse? _intelligence;
  bool _isLoading = false;
  bool _isLoadingFields = true;
  String? _errorMessage;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  Future<void> _initFields() async {
    final saved = await FieldStorageService.loadFields();
    setState(() {
      _fields = saved;
      _isLoadingFields = false;
    });
    if (_fields.isNotEmpty) _loadFieldIntelligence();
  }

  Future<void> _loadFieldIntelligence() async {
    if (_fields.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.getFieldIntelligence(
          _fields[_selectedFieldIndex].toRequest());
      setState(() {
        _intelligence = response;
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addField() async {
    final SavedField? newField = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFieldScreen()),
    );
    if (newField != null) {
      await FieldStorageService.addField(_fields, newField);
      setState(() {
        _selectedFieldIndex = _fields.length - 1;
        _intelligence = null;
      });
      _loadFieldIntelligence();
    }
  }

  Future<void> _deleteField(int index) async {
    final field = _fields[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Field', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        content: Text(
          'Remove "${field.fieldName}"?',
          style: const TextStyle(color: Color(0xFF78909C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF78909C))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Color(0xFFE05C5C))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FieldStorageService.removeField(_fields, index);
      setState(() {
        if (_selectedFieldIndex >= _fields.length) {
          _selectedFieldIndex = _fields.isEmpty ? 0 : _fields.length - 1;
        }
        _intelligence = null;
      });
      if (_fields.isNotEmpty) _loadFieldIntelligence();
    }
  }

  String _formatLastUpdated(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes == 1) return 'Updated 1 min ago';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours == 1) return 'Updated 1 hour ago';
    return 'Updated ${diff.inHours} hours ago';
  }

  void _selectField(int index) {
    if (index == _selectedFieldIndex) return;
    setState(() {
      _selectedFieldIndex = index;
      _intelligence = null;
    });
    _loadFieldIntelligence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_fields.length > 1) _buildFieldTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addField,
        backgroundColor: const Color(0xFF4A90D9),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final field = _fields.isNotEmpty ? _fields[_selectedFieldIndex] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FIELDSENSE',
                  style: TextStyle(
                    color: Color(0xFF4A90D9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  field?.fieldName ?? 'No Fields',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.5,
                  ),
                ),
                if (field?.cropType != null)
                  Text(
                    '${field!.cropType}${field.acreage != null ? '  ·  ${field.acreage!.toStringAsFixed(0)} acres' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF546E7A),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                if (_lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _formatLastUpdated(_lastUpdated!),
                      style: const TextStyle(
                        color: Color(0xFF2A3F55),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              if (field != null)
                IconButton(
                  onPressed: () => _deleteField(_selectedFieldIndex),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFF2A3F55), size: 20),
                ),
              IconButton(
                onPressed: _isLoading ? null : _loadFieldIntelligence,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFF4A90D9),
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, color: Color(0xFF2A3F55), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTabs() {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _fields.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFieldIndex;
          return GestureDetector(
            onTap: () => _selectField(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A90D9) : const Color(0xFF1A2535),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _fields[index].fieldName,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF78909C),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingFields) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90D9),
          strokeWidth: 1.5,
        ),
      );
    }

    if (_fields.isEmpty) return _buildEmptyState();

    if (_isLoading && _intelligence == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4A90D9), strokeWidth: 1.5),
            SizedBox(height: 16),
            Text(
              'Reading field conditions...',
              style: TextStyle(color: Color(0xFF546E7A), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _intelligence == null) return _buildErrorState();
    if (_intelligence == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _loadFieldIntelligence,
      color: const Color(0xFF4A90D9),
      backgroundColor: const Color(0xFF1A2535),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          RecommendationCard(recommendation: _intelligence!.recommendation),
          const SizedBox(height: 10),
          RainfallCard(rainfall: _intelligence!.rainfall),
          const SizedBox(height: 10),
          ForecastCard(forecast: _intelligence!.forecast),
          const SizedBox(height: 10),
          MoistureCard(moisture: _intelligence!.moisture),
          const SizedBox(height: 20),
          Text(
            '${_fields[_selectedFieldIndex].latitude.toStringAsFixed(4)}, ${_fields[_selectedFieldIndex].longitude.toStringAsFixed(4)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF1E2D3D), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.agriculture_outlined, size: 52, color: Color(0xFF1E2D3D)),
          const SizedBox(height: 20),
          const Text(
            'No fields added',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first field',
            style: TextStyle(color: Color(0xFF546E7A), fontSize: 14),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _addField,
            child: const Text(
              'Add Field',
              style: TextStyle(color: Color(0xFF4A90D9), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: Color(0xFF2A3F55)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF546E7A), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loadFieldIntelligence,
              child: const Text('Try Again', style: TextStyle(color: Color(0xFF4A90D9))),
            ),
          ],
        ),
      ),
    );
  }
}
