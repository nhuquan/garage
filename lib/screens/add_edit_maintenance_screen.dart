import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../models/maintenance_item.dart';
import '../theme/garage_theme.dart';

class AddEditMaintenanceScreen extends StatefulWidget {
  final String vehicleId;
  final MaintenanceItem? item;

  const AddEditMaintenanceScreen({super.key, required this.vehicleId, this.item});

  @override
  State<AddEditMaintenanceScreen> createState() => _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState extends State<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _costController;
  late TextEditingController _mileageController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _costController = TextEditingController(text: widget.item?.cost.toString() ?? '');
    _mileageController = TextEditingController(text: widget.item?.mileageAtService.toString() ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDate = widget.item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F0F0F),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final cost = double.parse(_costController.text);
      final mileage = double.parse(_mileageController.text);
      final notes = _notesController.text;

      final newItem = MaintenanceItem(
        id: widget.item?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: title,
        date: _selectedDate,
        cost: cost,
        mileageAtService: mileage,
        notes: notes,
      );

      if (widget.item == null) {
        context.read<GarageBloc>().add(AddMaintenanceRecord(newItem));
      } else {
        context.read<GarageBloc>().add(UpdateMaintenanceRecord(newItem));
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Service' : 'Edit Service'),
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
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Service Title (e.g. Oil Change)', Icons.build_rounded),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickDate,
                  child: _buildFieldWrapper(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, color: Colors.blueAccent),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat.yMMMMd().format(_selectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const Spacer(),
                        const Text('Change', style: TextStyle(color: Colors.blueAccent)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFieldWrapper(
                        child: TextFormField(
                          controller: _costController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration('Cost (\$)', Icons.attach_money_rounded),
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
                const SizedBox(height: 20),
                _buildFieldWrapper(
                  child: TextFormField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 4,
                    decoration: _buildInputDecoration('Notes', Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      widget.item == null ? 'Save Record' : 'Update Record',
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

  Widget _buildFieldWrapper({required Widget child, EdgeInsetsGeometry? padding}) {
    return GlassWidget(
      opacity: 0.1,
      borderRadius: 16,
      padding: padding,
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
