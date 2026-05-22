import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../database/app_database.dart';

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
  late TextEditingController _mileageController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _mileageController = TextEditingController(text: widget.item?.kmAtService.toString() ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDate = widget.item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final mileage = double.parse(_mileageController.text);
      final notes = _notesController.text;

      final newItem = MaintenanceItem(
        id: widget.item?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: title,
        date: _selectedDate,
        notes: notes, kmAtService: mileage,
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.item == null ? l10n.addRecord : l10n.editRecord),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    l10n.title,
                    Icon(Icons.build_rounded),
                    isDark,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickDate,
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.date,
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, color: Colors.blueAccent),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat.yMMMMd(l10n.localeName).format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Text(
                            l10n.localeName == 'vi' ? 'Thay đổi' : 'Change',
                            style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child:  TextFormField(
                        controller: _mileageController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          l10n.mileageAtService,
                          Icon(Icons.speed_rounded),
                          isDark,
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    l10n.notes,
                    Icon(Icons.notes_rounded),
                    isDark,
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

  InputDecoration _buildInputDecoration(String label, Icon icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon
    );
  }
}
