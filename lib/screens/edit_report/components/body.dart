import 'package:block1/constants.dart';
import 'package:block1/models/report.dart';
import 'package:block1/size_config.dart';
import 'package:flutter/material.dart';
import 'edit_report_form.dart';
// import 'edit_doctor_form.dart';

class Body extends StatelessWidget {
  final Report reportToEdit;

  const Body({Key key, this.reportToEdit}) : super(key: key);
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
                  "Fill Report Details",
                  style: headingStyle,
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                EditReportForm(report: reportToEdit),
                SizedBox(height: getProportionateScreenHeight(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
