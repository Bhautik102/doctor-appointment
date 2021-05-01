// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:block1/services/authentification/authentification_service.dart';


// class Req extends StatefulWidget {
//   @override
//   _ReqState createState() => _ReqState();
// }

// class _ReqState extends State<Req> {


//   String _uid = AuthentificationService().currentUser.uid;
//   var _list=[];
  
//   _req()async{
//     await FirebaseFirestore.instance.collection("users").doc(_uid).collection("appointment").get().then((value) {
//           for (var i in value.docs){
//             setState(() {
              
//             _list.add({"DoctorUID":i["DoctorUID"],"PatientUID":i["patientUid"],"HospitalName":i[""]});
//             });
//           }
          
//     });
//     print(_list);
//     print(_list[0]["DoctorUID"]);
//     setState(() {
      
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     //  _req();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: SafeArea(
//         child: _list.isEmpty? OutlinedButton(
//           child: Text("Get Appointment Details"),
//           onPressed: _req,
//         ):
//       ListView.builder(
//         itemCount: _list.length,
//         itemBuilder: (context, index) {
//         return Container(
//           child: Column(children: [
//             Text(_list[index]["DoctorUID"]),
//             Text(_list[index]["PatientUID"])
//           ],),
//         );
//       },)
//     ));
//   }
// }
// 
import 'package:intl/intl.dart';
import 'package:block1/constants.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:block1/size_config.dart';


class Req extends StatefulWidget {
  @override
  _ReqState createState() => _ReqState();
}

class _ReqState extends State<Req> {


  // String _uid = AuthentificationService().currentUser.uid;
  // var _list=[];
  
  // _req()async{
  //   await FirebaseFirestore.instance.collection("users").doc(_uid).collection("appointment").get().then((value) {
  //         for (var i in value.docs){
  //           setState(() {
              
  //           _list.add({"DoctorUID":i["DoctorUID"],"PatientUID":i["patientUid"],"HospitalName":i[""]});
  //           });
  //         }
          
  //   });
  //   print(_list);
  //   print(_list[0]["DoctorUID"]);
  //   setState(() {
      
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   //  _req();
  // }


DateTime dateToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) ; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointment"),),
      body:   Column(
        children: [

           SizedBox(height: getProportionateScreenHeight(10)),
                    Text(
                      "Your Pending Appoitments",
                      style: headingStyle,
                    ),
                    SizedBox(height: getProportionateScreenHeight(20)),
                 
                  

          Container(
    width: 500,
    height: 110,
    
    child: Card(
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.deepOrange[100],
          elevation: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               ListTile(
                leading: Icon(Icons.person, size: 70),
                title: Text('Name: Dipak Chahar ', style: TextStyle(color: Colors.white)),
                subtitle: Text('Doctor Name: Ghanshyam Patel Date: $dateToday', style: TextStyle(color: Colors.white)),
              ),
          
              // Container(
              
              //   child: ListTile(
                  
                  
              //     leading: Icon(Icons.local_hospital_sharp),
              //     title: Text(
                    
              //       "Patient Name: Dipak Ghelani",
                  
              //       style: TextStyle(fontSize: 16, color: Colors.black),
              //     ),
                  
              //     subtitle: Text("Doctor Name: Ghanshyam Patel      Date: $dateToday "),



              //     // onTap: () async {
              //     //   bool allowed = AuthentificationService().currentUserVerified;
              //     //   if (!allowed) {
              //     //     final reverify = await showConfirmationDialog(context,
              //     //         "You haven't verified your email address. This action is only allowed for verified users.",
              //     //         positiveResponse: "Resend verification email",
              //     //         negativeResponse: "Go back");
              //     //     if (reverify) {
              //     //       final future = AuthentificationService()
              //     //           .sendVerificationEmailToCurrentUser();
              //     //       await showDialog(
              //     //         context: context,
              //     //         builder: (context) {
              //     //           return FutureProgressDialog(
              //     //             future,
              //     //             message: Text("Resending verification email"),
              //     //           );
              //     //         },
              //     //       );
              //     //     }
              //     //     return;
              //     //   }
              //     //   Navigator.push(
              //     //     context,
              //     //     MaterialPageRoute(
              //     //       builder: (context) => ManageAddressesScreen(),
              //     //     ),
              //     //   );
              //     // },
              //   ),
              // ),
              
             
              

               
              
            ] 
          )
            
    )
    ),
        ],
      )
    );

    

 
  }
}