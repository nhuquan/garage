import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../models/maintenance_item.dart';
import '../models/maintenance_type.dart';
import '../widgets/glass_widget.dart';

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
  late MaintenanceType _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _costController = TextEditingController(
      text: widget.item != null && widget.item!.cost > 0 ? widget.item!.cost.toString() : '',
    );
    _mileageController = TextEditingController(text: widget.item?.mileageAtService.toString() ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedDate = widget.item?.date ?? DateTime.now();
    _selectedType = widget.item?.type ?? MaintenanceType.other;
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
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final cost = double.tryParse(_costController.text) ?? 0.0;
      final mileage = double.parse(_mileageController.text);
      final notes = _notesController.text;

      final newItem = MaintenanceItem(
        id: widget.item?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: title,
        type: _selectedType,
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencySymbol = NumberFormat.simpleCurrency(locale: l10n?.localeName).currencySymbol;

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
              _buildFieldWrapper(
                child: TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    l10n.title,
                    Icons.build_rounded,
                    isDark,
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildFieldWrapper(
                child: DropdownButtonFormField<MaintenanceType>(
                  value: _selectedType,
                  decoration: _buildInputDecoration(
                    l10n.serviceType,
                    _selectedType.icon,
                    isDark,
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  items: MaintenanceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.localizedName(l10n)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        if (_titleController.text.isEmpty || 
                            MaintenanceType.values.any((e) => e.localizedName(l10n) == _titleController.text)) {
                          _titleController.text = value.localizedName(l10n);
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickDate,
                child: _buildFieldWrapper(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
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
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildFieldWrapper(
                      child: TextFormField(
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          '${l10n.cost} ($currencySymbol) ${l10n.optional}',
                          Icons.payments_rounded,
                          isDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildFieldWrapper(
                      child: TextFormField(
                        controller: _mileageController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          l10n.mileageAtService,
                          Icons.speed_rounded,
                          isDark,
                        ),
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
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    l10n.notes,
                    Icons.notes_rounded,
                    isDark,
                  ),
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

  Widget _buildFieldWrapper({required Widget child, EdgeInsetsGeometry? padding}) {
    return GlassWidget(
      opacity: 0.08,
      borderRadius: 16,
      padding: padding,
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: Colors.blueAccent[100],
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: label,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      filled: true,
      fillColor: Colors.transparent,
    );
  }
}
