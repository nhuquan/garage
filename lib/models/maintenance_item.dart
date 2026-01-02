import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

class MaintenanceItem extends Equatable {
  final String id;
  final String vehicleId;
  final String title;
  final DateTime date;
  final double cost;
  final double mileageAtService;
  final String notes;

  const MaintenanceItem({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.date,
    required this.cost,
    required this.mileageAtService,
    required this.notes,
  });

  MaintenanceItem copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DateTime? date,
    double? cost,
    double? mileageAtService,
    String? notes,
  }) {
    return MaintenanceItem(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      date: date ?? this.date,
      cost: cost ?? this.cost,
      mileageAtService: mileageAtService ?? this.mileageAtService,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, vehicleId, title, date, cost, mileageAtService, notes];
}

class MaintenanceItemAdapter extends TypeAdapter<MaintenanceItem> {
  @override
  final int typeId = 1;

  @override
  MaintenanceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceItem(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      title: fields[2] as String,
      date: fields[3] as DateTime,
      cost: fields[4] as double,
      mileageAtService: fields[5] as double,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.mileageAtService)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
