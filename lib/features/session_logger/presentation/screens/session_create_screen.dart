import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/models/training_session.dart';
import '../../domain/models/target_face.dart';
import '../providers/session_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Screen for creating a new training session
class SessionCreateScreen extends ConsumerStatefulWidget {
  const SessionCreateScreen({super.key});

  @override
  ConsumerState<SessionCreateScreen> createState() => _SessionCreateScreenState();
}

class _SessionCreateScreenState extends ConsumerState<SessionCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _distanceController = TextEditingController(text: '18');
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedBowType = AppConstants.bowTypes.first;
  TargetType _selectedTargetType = TargetType.fita;

  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final distance = double.tryParse(_distanceController.text) ?? 18.0;
      
      // Create appropriate target face
      TargetFace targetFace;
      if (_selectedTargetType == TargetType.fita) {
        targetFace = TargetFace.fita122();
      } else {
        targetFace = TargetFace(
          type: _selectedTargetType,
          diameterCm: 122.0,
          scoringZones: const {}, // TODO: Add other target types
        );
      }

      final session = TrainingSession(
        id: const Uuid().v4(),
        userId: user.uid,
        date: _selectedDate,
        location: _locationController.text.trim(),
        bowType: _selectedBowType,
        distanceMeters: distance,
        targetFace: targetFace,
        ends: [],
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      final createSession = ref.read(createSessionProvider);
      await createSession(session);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Training Session'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Date Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Indoor Range, Outdoor Field',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Bow Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBowType,
              decoration: const InputDecoration(
                labelText: 'Bow Type',
                prefixIcon: Icon(Icons.adjust),
              ),
              items: AppConstants.bowTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBowType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Distance
            TextFormField(
              controller: _distanceController,
              decoration: const InputDecoration(
                labelText: 'Distance (meters)',
                hintText: '18',
                prefixIcon: Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter distance';
                }
                final distance = double.tryParse(value);
                if (distance == null || distance <= 0) {
                  return 'Please enter a valid distance';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Target Type
            DropdownButtonFormField<TargetType>(
              value: _selectedTargetType,
              decoration: const InputDecoration(
                labelText: 'Target Type',
                prefixIcon: Icon(Icons.gps_fixed),
              ),
              items: const [
                DropdownMenuItem(
                  value: TargetType.fita,
                  child: Text('FITA/WA 10-ring'),
                ),
                DropdownMenuItem(
                  value: TargetType.field,
                  child: Text('Field'),
                ),
                DropdownMenuItem(
                  value: TargetType.threeD,
                  child: Text('3D'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTargetType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any notes about this session...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _createSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Session'),
            ),
          ],
        ),
      ),
    );
  }
}
