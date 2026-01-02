// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appearance => 'Giao diện';

  @override
  String get appTitle => 'Garage';

  @override
  String get home => 'Trang chủ';

  @override
  String get history => 'Lịch sử';

  @override
  String get settings => 'Cài đặt';

  @override
  String get logout => 'Đăng xuất';

  @override
  String greeting(String username) {
    return 'Xin chào, $username';
  }

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get password => 'Mật khẩu';

  @override
  String get darkTheme => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get addVehicle => 'Thêm xe';

  @override
  String get editVehicle => 'Sửa thông tin xe';

  @override
  String get vehicleName => 'Tên xe';

  @override
  String get vehicleType => 'Loại xe';

  @override
  String get year => 'Năm sản xuất';

  @override
  String get currentMileage => 'Số km hiện tại';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get maintenanceHistory => 'Lịch sử bảo trì';

  @override
  String get addRecord => 'Thêm bản ghi';

  @override
  String get editRecord => 'Sửa bản ghi';

  @override
  String get title => 'Tiêu đề';

  @override
  String get date => 'Ngày';

  @override
  String get cost => 'Chi phí';

  @override
  String get mileageAtService => 'Số km khi bảo trì';

  @override
  String get notes => 'Ghi chú';

  @override
  String get optional => '(Tùy chọn)';

  @override
  String get noVehicles => 'Không tìm thấy xe nào. Hãy thêm mới!';

  @override
  String get noMaintenance => 'Không có bản ghi bảo trì nào.';
}
