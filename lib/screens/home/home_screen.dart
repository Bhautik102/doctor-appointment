import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../../size_config.dart';
import 'components/body.dart';
import 'components/home_screen_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/home";

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
  //  String uid;

  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final FirebaseMessaging _fcm = FirebaseMessaging();

  // StreamSubscription iosSubscription;

  // @override
  // void initState() {

// //    
//     super.initState();
//     if (Platform.isIOS) {
//       iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
//         print(data);
    //     _saveDeviceToken();
    //   });

    //   _fcm.requestNotificationPermissions(IosNotificationSettings());
    // } else {
    //   _saveDeviceToken();
    // }

    // _fcm.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
       //   content: Text(message['notification']['title']),
        //   action: SnackBarAction(
        //     label: 'Go',
        //     onPressed: () => null,
        //   ),
        // );

        // Scaffold.of(context).showSnackBar(snackbar); // final snackbar = SnackBar(
        
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //               content: ListTile(
  //                 title: Text(message['notification']['title']),
  //                 subtitle: Text(message['notification']['body']),
  //               ),
  //               actions: <Widget>[
  //                 FlatButton(
  //                   color: Colors.amber,
  //                   child: Text('Ok'),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 ),
  //               ],
  //             ),
  //       );
  //     },
  //     onLaunch: (Map<String, dynamic> message) async {
  //       print("onLaunch: $message");
  //       // TODO optional
  //     },
  //     onResume: (Map<String, dynamic> message) async {
  //       print("onResume: $message");
  //       // TODO optional
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   if (iosSubscription != null) iosSubscription.cancel();
  //   super.dispose();
  // }
  
  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Body(),
      drawer: HomeScreenDrawer(),
    );
  }


//  _saveDeviceToken() async {
//     // Get the current user
//     // String uid = uid;
//     String uid;
//     // FirebaseUser user = await _auth.currentUser();
//  setState(() {
  
//  uid=AuthentificationService().current_user();
// });
//     // Get the token for this device
//     String fcmToken = await _fcm.getToken();

//     // Save it to Firestore
//     if (fcmToken != null) {
//       var tokens = _db
//           .collection('users')
//           .doc(uid)
//           .collection('tokens')
//           .doc(fcmToken);

//       await tokens.set({
//         'token': fcmToken,
//         'createdAt': FieldValue.serverTimestamp(), // optional
//         'platform': Platform.operatingSystem // optional
//       });
//     }
//   }

//   /// Subscribe the user to a topic
//   _subscribeToTopic() async {
//     // Subscribe the user to a topic
//     _fcm.subscribeToTopic('puppies');
//   }
}
