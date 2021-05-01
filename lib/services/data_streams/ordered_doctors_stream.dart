import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/user_database_helper.dart';

class OrderedDoctorsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final orderedDoctorsFuture = UserDatabaseHelper().orderedDoctorsList;
    orderedDoctorsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
