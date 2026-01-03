import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../models/vehicle.dart';
import '../widgets/glass_widget.dart';

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
  late TextEditingController _descriptionController;
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
    _descriptionController = TextEditingController(text: widget.vehicle?.description ?? '');
    _selectedType = widget.vehicle?.type ?? 'Car';
  }

  @override
  void dispose() {
    _nameController = disposeController(_nameController);
    _yearController = disposeController(_yearController);
    _descriptionController = disposeController(_descriptionController);
    super.dispose();
  }

  TextEditingController disposeController(TextEditingController controller) {
    controller.dispose();
    return controller;
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final year = int.parse(_yearController.text);

      if (widget.vehicle == null) {
        final newVehicle = Vehicle(
          id: const Uuid().v4(),
          name: name,
          type: _selectedType,
          year: year,
          currentMileage: 0,
          description: _descriptionController.text,
        );
        context.read<GarageBloc>().add(AddVehicle(newVehicle));
      } else {
        final updatedVehicle = widget.vehicle!.copyWith(
          name: name,
          type: _selectedType,
          year: year,
          description: _descriptionController.text,
        );
        context.read<GarageBloc>().add(UpdateVehicle(updatedVehicle));
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.vehicle == null ? l10n.addVehicle : l10n.editVehicle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(l10n.vehicleName, Icons.badge_rounded, isDark),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                  value: _selectedType,
                  dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  items: _categories
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                  decoration: _buildInputDecoration(l10n.vehicleType, Icons.category_rounded, isDark),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(l10n.year, Icons.calendar_today_rounded, isDark),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  l10n.localeName == 'vi' ? 'Mô tả' : 'Description',
                  Icons.description_rounded,
                  isDark,
                ).copyWith(
                  alignLabelWithHint: true,
                ),
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
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueAccent)
    );
  }
}
