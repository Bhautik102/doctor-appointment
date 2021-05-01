import 'package:block1/models/Doctor.dart';
import 'package:block1/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import 'expandable_text.dart';

class DoctorDescription extends StatelessWidget {
  const DoctorDescription({
    Key key,
    @required this.doctor,
  }) : super(key: key);

  final Doctor doctor;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                  text: doctor.title,
                  style: TextStyle(
                    fontSize: 21,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: "\n${doctor.qualification} ",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 16),
            // SizedBox(
            //   height: getProportionateScreenHeight(64),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Flexible(
            //         flex: 4,
            //         child: Text.rich(
            //           TextSpan(
            //             text: "\₹${doctor.discountPrice}   ",
            //             style: TextStyle(
            //               color: kPrimaryColor,
            //               fontWeight: FontWeight.w900,
            //               fontSize: 24,
            //             ),
            //             children: [
            //               TextSpan(
            //                 text: "\n\₹${doctor.originalPrice}",
            //                 style: TextStyle(
            //                   decoration: TextDecoration.lineThrough,
            //                   color: kTextColor,
            //                   fontWeight: FontWeight.normal,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       Flexible(
            //         flex: 3,
            //         child: Stack(
            //           children: [
            //             SvgPicture.asset(
            //               "assets/icons/Discount.svg",
            //               color: kPrimaryColor,
            //             ),
            //             Center(
            //               child: Text(
            //                 "${doctor.calculatePercentageDiscount()}%\nOff",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: getProportionateScreenHeight(15),
            //                   fontWeight: FontWeight.w900,
            //                 ),
            //                 textAlign: TextAlign.center,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 16),
            ExpandableText(
              title: "Highlights",
              content: doctor.highlights,
            ),
            const SizedBox(height: 16),
            ExpandableText(
              title: "Description",
              content: doctor.description,
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: "Fulfilled by ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "${doctor.hospitalName}",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
