import 'package:block1/models/Doctor.dart';
import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';

class CategoryDoctorsStream extends DataStream<List<String>> {
  final DoctorType category;

  CategoryDoctorsStream(this.category);
  @override
  void reload() {
    final allDoctorsFuture =
        DoctorDatabaseHelper().getCategoryDoctorsList(category);
    allDoctorsFuture.then((favDoctors) {
      addData(favDoctors);
    }).catchError((e) {
      addError(e);
    });
  }
}
