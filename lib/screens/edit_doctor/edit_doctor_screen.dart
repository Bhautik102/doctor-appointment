import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/edit_doctor/provider_models/DoctorDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/body.dart';

class EditDoctorScreen extends StatelessWidget {
  final Doctor doctorToEdit;

  const EditDoctorScreen({Key key, this.doctorToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoctorDetails(),
      child: Scaffold(
        appBar: AppBar(),
        body: Body(
          doctorToEdit: doctorToEdit,
        ),
      ),
    );
  }
}
