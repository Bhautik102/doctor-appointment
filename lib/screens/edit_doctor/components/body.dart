import 'package:block1/constants.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/size_config.dart';
import 'package:flutter/material.dart';

import 'edit_doctor_form.dart';

class Body extends StatelessWidget {
  final Doctor doctorToEdit;

  const Body({Key key, this.doctorToEdit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "Fill Doctor Details",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                EditDoctorForm(doctor: doctorToEdit),
                SizedBox(height: getProportionateScreenHeight(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
