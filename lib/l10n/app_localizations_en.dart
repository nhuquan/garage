// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appearance => 'Appearance';

  @override
  String get appTitle => 'Garage';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String greeting(String username) {
    return 'Hello, $username';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get vehicleName => 'Vehicle Name';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get year => 'Year';

  @override
  String get currentMileage => 'Current Mileage';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get maintenanceHistory => 'Maintenance History';

  @override
  String get addRecord => 'Add Record';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get title => 'Title';

  @override
  String get date => 'Date';

  @override
  String get cost => 'Cost';

  @override
  String get mileageAtService => 'Mileage at Service';

  @override
  String get notes => 'Notes';

  @override
  String get optional => '(Optional)';

  @override
  String get noVehicles => 'No vehicles found. Add one!';

  @override
  String get noMaintenance => 'No maintenance records found.';
}
