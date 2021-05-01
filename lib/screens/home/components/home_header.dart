import 'package:block1/components/rounded_icon_button.dart';
import 'package:block1/components/search_field.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../components/icon_button_with_counter.dart';

class HomeHeader extends StatefulWidget {
  final Function onSearchSubmitted;
  final Function onCartButtonPressed;
  const HomeHeader({
    Key key,
    @required this.onSearchSubmitted,
    @required this.onCartButtonPressed,
  }) : super(key: key);

  @override
  _HomeHeaderState createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
    String uid;
  String usertype;
 
  @override
  Widget build(BuildContext context) {
    
    setState(() {
  
 uid=AuthentificationService().current_user();
});
  FirebaseFirestore.instance.collection("users").get().then((value) {
      value.docs.forEach((element) { 
        if(element.data()["uid"]==uid){
          setState(() {
            usertype=element.data()["userType"];
          });
          print(element.data()["success"]);
        }
      });
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
            iconData: Icons.menu,
            press: () {
              Scaffold.of(context).openDrawer();
            }),
        Expanded(
          child: SearchField(
            onSubmit: widget.onSearchSubmitted,
          ),
        ),
        SizedBox(width: 5),
                        if(usertype=="PATIENT")

        IconButtonWithCounter(
          svgSrc: "assets/icons/Cart_icon.svg",
          numOfItems: 0,
          press: widget.onCartButtonPressed,
        ),
      ],
    );
  }
}
