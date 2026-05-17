// home_screen.dart
// Main FieldSense dashboard. Shows field intelligence for saved fields.

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
  final List<SavedField> _fields = [];
  int _selectedFieldIndex = 0;

  FieldIntelligenceResponse? _intelligence;
  bool _isLoading = false;
  String? _errorMessage;

  bool _isLoadingFields = true;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  Future<void> _initFields() async {
    final saved = await FieldStorageService.loadFields();
    setState(() {
      _fields.addAll(saved);
      _isLoadingFields = false;
    });
    if (_fields.isNotEmpty) {
      _loadFieldIntelligence();
    }
  }

  Future<void> _loadFieldIntelligence() async {
    if (_fields.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final field = _fields[_selectedFieldIndex];
      final response =
          await ApiService.getFieldIntelligence(field.toRequest());
      setState(() {
        _intelligence = response;
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
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Remove Field',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${field.fieldName}" from FieldSense?',
          style: const TextStyle(color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF8E8E93))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: Color(0xFFEF5350))),
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_fields.length > 1) _buildFieldSelector(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addField,
        backgroundColor: const Color(0xFF66BB6A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final field =
        _fields.isNotEmpty ? _fields[_selectedFieldIndex] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FieldSense',
                style: TextStyle(
                  color: Color(0xFF66BB6A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                field?.fieldName ?? 'No Fields',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (field?.cropType != null)
                Text(
                  '${field!.cropType}${field.acreage != null ? ' · ${field.acreage!.toStringAsFixed(0)} ac' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (field != null)
                IconButton(
                  onPressed: () => _deleteField(_selectedFieldIndex),
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFF3A3A3C), size: 20),
                ),
              IconButton(
                onPressed: _isLoading ? null : _loadFieldIntelligence,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF66BB6A),
                    ),
                  )
                : const Icon(Icons.refresh_outlined,
                    color: Color(0xFF8E8E93)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _fields.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFieldIndex;
          return GestureDetector(
            onTap: () => _selectField(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF66BB6A)
                    : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _fields[index].fieldName,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
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
        child: CircularProgressIndicator(color: Color(0xFF66BB6A)),
      );
    }

    if (_fields.isEmpty) {
      return _buildEmptyState();
    }

    if (_isLoading && _intelligence == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF66BB6A)),
            SizedBox(height: 16),
            Text(
              'Analyzing field conditions...',
              style: TextStyle(color: Color(0xFF8E8E93)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _intelligence == null) {
      return _buildErrorState();
    }

    if (_intelligence == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _loadFieldIntelligence,
      color: const Color(0xFF66BB6A),
      backgroundColor: const Color(0xFF1C1C1E),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          RecommendationCard(
              recommendation: _intelligence!.recommendation),
          const SizedBox(height: 12),
          RainfallCard(rainfall: _intelligence!.rainfall),
          const SizedBox(height: 12),
          ForecastCard(forecast: _intelligence!.forecast),
          const SizedBox(height: 12),
          MoistureCard(moisture: _intelligence!.moisture),
          const SizedBox(height: 12),
          _buildLocationFooter(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.agriculture_outlined,
              size: 64, color: Color(0xFF2C2C2E)),
          const SizedBox(height: 16),
          const Text(
            'No fields added yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first field',
            style: TextStyle(color: Color(0xFF8E8E93)),
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
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: Color(0xFF8E8E93)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFieldIntelligence,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFooter() {
    final field = _fields[_selectedFieldIndex];
    return Text(
      '${field.latitude.toStringAsFixed(4)}, ${field.longitude.toStringAsFixed(4)}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF3A3A3C),
        fontSize: 11,
      ),
    );
  }
}