import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import '../constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:block1/models/Doctor.dart';
// import 'package:block1/services/authentification/authentification_service.dart';
// import 'package:block1/services/database/user_database_helper.dart';

class DoctorCard extends StatefulWidget {
  final String doctorId;
  final GestureTapCallback press;
  const DoctorCard({
    Key key,
    @required this.doctorId,
    @required this.press,
  }) : super(key: key);

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  // String uid;
  // String dname;
  @override
  Widget build(BuildContext context) {

//     setState(() {
  
//  uid=AuthentificationService().current_user();
// });
//   FirebaseFirestore.instance.collection("users").get().then((value) {
//       value.docs.forEach((element) { 
//         if(element.data()["uid"]==dname){
//           setState(() {
//             dname=element.data()["hospitalName"];
//           });
//           // print(element.data()["success"]);
//         }
//       });
//     });
    
    return GestureDetector(
      onTap: widget.press,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kTextColor.withOpacity(0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder<Doctor>(
            future: DoctorDatabaseHelper().getDoctorWithID(widget.doctorId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final Doctor doctor = snapshot.data;
                return buildDoctorCardItems(doctor);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Center(child: CircularProgressIndicator()),
                );
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

  Column buildDoctorCardItems(Doctor doctor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              doctor.images[0],
              fit: BoxFit.fitWidth,
              
            ),
          ),
        ),
        SizedBox(height: 10),
        Flexible(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                 "Name: " "${doctor.title}\n",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5),
              //  Flexible(
              //   flex: 1,
              //   child: Text(
              //    "Degree: " "${doctor.qualification}\n",
              //     style: TextStyle(
              //       color: kTextColor,
              //       fontSize: 13,
              //       fontWeight: FontWeight.bold,
              //     ),
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
               Flexible(
                flex: 1,
                child: Text(
                 "Hospital Name: " "${doctor.hospitalName}\n",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Flexible(
              //   flex: 1,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Flexible(
              //   flex: 1,
              //   child: Text(
              //    "Degree: " "${doctor.qualification}\n",
              //     style: TextStyle(
              //       color: kTextColor,
              //       fontSize: 13,
              //       fontWeight: FontWeight.bold,
              //     ),
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
              //  SizedBox(height: 5),
              //  Flexible(
              //   flex: 1,
              //   child: Text(
              //    "Degree: " "${doctor.seller}\n",
              //     style: TextStyle(
              //       color: kTextColor,
              //       fontSize: 13,
              //       fontWeight: FontWeight.bold,
              //     ),
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
                    // Flexible(
                    //   flex: 5,
                    //   child: Text.rich(
                    //     TextSpan(
                    //       text: "\₹${doctor.discountPrice}\n",
                    //       style: TextStyle(
                    //         color: kPrimaryColor,
                    //         fontWeight: FontWeight.w700,
                    //         fontSize: 12,
                    //       ),
                    //       children: [
                    //         TextSpan(
                    //           text: "\₹${doctor.originalPrice}",
                    //           style: TextStyle(
                    //             color: kTextColor,
                    //             decoration: TextDecoration.lineThrough,
                    //             fontWeight: FontWeight.normal,
                    //             fontSize: 11,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Flexible(
                    //   flex: 3,
                    //   child: Stack(
                    //     children: [
                    //       SvgPicture.asset(
                    //         "assets/icons/DiscountTag.svg",
                    //         color: kPrimaryColor,
                    //       ),
                    //       Center(
                    //         child: Text(
                    //           "${doctor.calculatePercentageDiscount()}%\nOff",
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 8,
                    //             fontWeight: FontWeight.w900,
                    //           ),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          
      
    
    );
  }
}
