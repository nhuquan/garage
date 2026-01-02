import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../models/vehicle.dart';
import '../theme/garage_theme.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  String _selectedType = 'Car';

  final List<String> _categories = [
    'Car',
    'Motorcycle',
    'Bicycle',
    'Truck',
    'Boat',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _yearController = TextEditingController(text: widget.vehicle?.year.toString() ?? '');
    _mileageController = TextEditingController(text: widget.vehicle?.currentMileage.toString() ?? '');
    _selectedType = widget.vehicle?.type ?? 'Car';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final year = int.parse(_yearController.text);
      final mileage = double.parse(_mileageController.text);

      if (widget.vehicle == null) {
        final newVehicle = Vehicle(
          id: const Uuid().v4(),
          name: name,
          type: _selectedType,
          year: year,
          currentMileage: mileage,
        );
        context.read<GarageBloc>().add(AddVehicle(newVehicle));
      } else {
        final updatedVehicle = widget.vehicle!.copyWith(
          name: name,
          type: _selectedType,
          year: year,
          currentMileage: mileage,
        );
        context.read<GarageBloc>().add(UpdateVehicle(updatedVehicle));
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'New Vehicle' : 'Edit Vehicle'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F0F), Color(0xFF1E1E2F)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFieldWrapper(
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Vehicle Name', Icons.badge_rounded),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFieldWrapper(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Category', Icons.category_rounded),
                    items: _categories
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWrapper(
                        child: TextFormField(
                          controller: _yearController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Year', Icons.calendar_today_rounded),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFieldWrapper(
                        child: TextFormField(
                          controller: _mileageController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Mileage', Icons.speed_rounded),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                    ),
                    child: Text(
                      widget.vehicle == null ? 'Add to Garage' : 'Save Changes',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWrapper({required Widget child}) {
    return GlassWidget(
      opacity: 0.1,
      borderRadius: 16,
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
