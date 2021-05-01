import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';

class UsersDoctorsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final usersDoctorsFuture = DoctorDatabaseHelper().usersDoctorsList;
    usersDoctorsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
