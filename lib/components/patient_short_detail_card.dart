// // import 'package:block1/models/Doctor.dart';
// // import 'package:block1/services/database/doctor_database_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

// import '../constants.dart';
// import '../size_config.dart';

// class PatientShortDetailCard extends StatelessWidget {
//   // final String doctorId;
//   final VoidCallback onPressed;
//   const PatientShortDetailCard({
//     Key key,
//     // @required this.doctorId,
//     @required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       child: FutureBuilder<Doctor>(
//         future: DoctorDatabaseHelper().getDoctorWithID(doctorId),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final doctor = snapshot.data;
//             return Row(
//               children: [
//                 SizedBox(
//                   width: getProportionateScreenWidth(88),
//                   child: AspectRatio(
//                     aspectRatio: 0.88,
//                     child: Padding(
//                       padding: EdgeInsets.all(10),
//                       child: doctor.images.length > 0
//                           ? Image.network(
//                               doctor.images[0],
//                               fit: BoxFit.contain,
//                             )
//                           : Text("No Image"),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: getProportionateScreenWidth(20)),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         doctor.title,
//                         softWrap: true,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                           color: kTextColor,
//                         ),
//                         maxLines: 2,
//                       ),
//                       SizedBox(height: 10),
//                       // Text.rich(
//                       //   TextSpan(
//                       //       text: "\₹${doctor.discountPrice}    ",
//                       //       style: TextStyle(
//                       //         color: kPrimaryColor,
//                       //         fontWeight: FontWeight.w700,
//                       //         fontSize: 12,
//                       //       ),
//                       //       children: [
//                       //         TextSpan(
//                       //           text: "\₹${doctor.originalPrice}",
//                       //           style: TextStyle(
//                       //             color: kTextColor,
//                       //             decoration: TextDecoration.lineThrough,
//                       //             fontWeight: FontWeight.normal,
//                       //             fontSize: 11,
//                       //           ),
//                       //         ),
//                       //       ]),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             final errorMessage = snapshot.error.toString();
//             Logger().e(errorMessage);
//           }
//           return Center(
//             child: Icon(
//               Icons.error,
//               color: kTextColor,
//               size: 60,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
