import 'package:block1/constants.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/doctor_details/components/doctor_review_section.dart';
import 'package:block1/screens/doctor_details/components/date.dart';
import 'package:block1/screens/doctor_details/components/doctor_actions_section.dart';
import 'package:block1/screens/doctor_details/components/doctor_images.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/size_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'doctor_review_section.dart';

class Body extends StatelessWidget {
  final String doctorId;

  const Body({
    Key key,
    @required this.doctorId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: FutureBuilder<Doctor>(
            future: DoctorDatabaseHelper().getDoctorWithID(doctorId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final doctor = snapshot.data;
                return Column(
                  children: [
                    DoctorImages(doctor: doctor),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    DoctorActionsSection(doctor: doctor),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    DoctorReviewsSection(doctor: doctor),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    DateSelectSection(doctor: doctor),
                    SizedBox(height: getProportionateScreenHeight(100)),

                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                final error = snapshot.error.toString();
                Logger().e(error);
              }
              return Center(
                child: Icon(
                  Icons.error,
                  color: kTextColor,
                  size: 60,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
