import 'package:block1/models/Doctor.dart';

import 'package:flutter/material.dart';

import 'components/body.dart';

class CategoryDoctorsScreen extends StatelessWidget {
  final DoctorType doctorType;

  const CategoryDoctorsScreen({
    Key key,
    @required this.doctorType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        doctorType: doctorType,
      ),
    );
  }
}
