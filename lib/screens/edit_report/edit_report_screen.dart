// import 'package:block1/screens/edit_doctor/provider_models/DoctorDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './components/body.dart';
import 'package:block1/models/report.dart';
import './provider/report_detail.dart';
class EditReportScreen extends StatelessWidget {
  final Report reportToEdit;

  const EditReportScreen({Key key, this.reportToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
     create: (context) => ReportDetails(),
      child: Scaffold(
        appBar: AppBar(),
        body: Body(
          reportToEdit: reportToEdit,
        ),
      ),
    );
  }
}
