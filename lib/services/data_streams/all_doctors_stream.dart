import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';

class AllDoctorsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final allDoctorsFuture = DoctorDatabaseHelper().allDoctorsList;
    allDoctorsFuture.then((favDoctors) {
      addData(favDoctors);
    }).catchError((e) {
      addError(e);
    });
  }
}
