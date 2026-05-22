import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../database/app_database.dart';

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
  bool _useCustomInterval = false;
  int _customIntervalMonths = 6;

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
    final existingOverride = widget.vehicle?.maintenanceIntervalMonths;
    _useCustomInterval = existingOverride != null;
    _customIntervalMonths = existingOverride?.clamp(3, 9) ?? 6;
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
      final intervalOverride = _useCustomInterval ? _customIntervalMonths : null;

      if (widget.vehicle == null) {
        final newVehicle = Vehicle(
          id: const Uuid().v4(),
          name: name,
          type: _selectedType,
          year: year,
          currentKm: 0,
          description: _descriptionController.text,
          maintenanceIntervalMonths: intervalOverride,
        );
        context.read<GarageBloc>().add(AddVehicle(newVehicle));
      } else {
        final updatedVehicle = widget.vehicle!.copyWith(
          name: name,
          type: _selectedType,
          year: year,
          description: _descriptionController.text,
          maintenanceIntervalMonths: Value(intervalOverride),
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
              const SizedBox(height: 20),
              BlocBuilder<GarageBloc, GarageState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.build_rounded,
                                color: Colors.blueAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.localeName == 'vi'
                                    ? 'Ghi đè chu kỳ bảo dưỡng'
                                    : 'Custom service interval',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Switch(
                              value: _useCustomInterval,
                              activeColor: Colors.blueAccent,
                              onChanged: (v) =>
                                  setState(() => _useCustomInterval = v),
                            ),
                          ],
                        ),
                        if (_useCustomInterval) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  l10n.localeName == 'vi'
                                      ? '3 tháng'
                                      : '3 months',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).hintColor),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  l10n.localeName == 'vi'
                                      ? '$_customIntervalMonths tháng'
                                      : '$_customIntervalMonths months',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  l10n.localeName == 'vi'
                                      ? '9 tháng'
                                      : '9 months',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).hintColor),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: Colors.blueAccent,
                              inactiveTrackColor:
                                  Colors.blueAccent.withOpacity(0.2),
                              thumbColor: Colors.blueAccent,
                              overlayColor: Colors.blueAccent.withOpacity(0.1),
                              valueIndicatorColor: Colors.blueAccent,
                              showValueIndicator: ShowValueIndicator.always,
                              valueIndicatorTextStyle: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            child: Slider(
                              value: _customIntervalMonths.toDouble(),
                              min: 3,
                              max: 9,
                              divisions: 6,
                              label: l10n.localeName == 'vi'
                                  ? '$_customIntervalMonths tháng'
                                  : '$_customIntervalMonths months',
                              onChanged: (v) => setState(
                                  () => _customIntervalMonths = v.round()),
                            ),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(left: 30, top: 2, bottom: 6),
                            child: Text(
                              l10n.localeName == 'vi'
                                  ? 'Dùng cài đặt chung: ${state.maintenanceIntervalMonths} tháng'
                                  : 'Using global setting: ${state.maintenanceIntervalMonths} months',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
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
