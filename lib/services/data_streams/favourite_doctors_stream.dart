import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/user_database_helper.dart';

class FavouriteDoctorsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final favDoctorsFuture = UserDatabaseHelper().usersFavouriteDoctorsList;
    favDoctorsFuture.then((favDoctors) {
      addData(favDoctors.cast<String>());
    }).catchError((e) {
      addError(e);
    });
  }
}
