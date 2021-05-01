import 'package:block1/services/data_streams/data_stream.dart';
import 'package:block1/services/database/report_database_helper.dart';
import 'package:block1/services/database/user_database_helper.dart';

class UsersReportsStream extends DataStream<List<String>> {
  @override
  void reload() {
    final usersReportsFuture = UserDatabaseHelper().usersReportsList;
    usersReportsFuture.then((data) {
      addData(data);
    }).catchError((e) {
      addError(e);
    });
  }
}
