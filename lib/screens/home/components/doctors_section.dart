import 'package:block1/components/nothingtoshow_container.dart';
import 'package:block1/components/doctor_card.dart';
import 'package:block1/screens/home/components/section_tile.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:block1/services/data_streams/data_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../size_config.dart';

class DoctorsSection extends StatefulWidget {
  final String sectionTitle;
  final DataStream doctorsStreamController;
  final String emptyListMessage;
  final Function onDoctorCardTapped;
  const DoctorsSection({
    Key key,
    @required this.sectionTitle,
    @required this.doctorsStreamController,
    this.emptyListMessage = "No Doctors to show here",
    @required this.onDoctorCardTapped,
  }) : super(key: key);

  @override
  _DoctorsSectionState createState() => _DoctorsSectionState();
}

class _DoctorsSectionState extends State<DoctorsSection> {

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

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          SectionTile(
            title: widget.sectionTitle,
            press: () {},
          ),
          SizedBox(height: getProportionateScreenHeight(15)),
          Expanded(
            child: buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget buildDoctorsList() {
    return StreamBuilder<List<String>>(
      stream: widget.doctorsStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Center(
              child: NothingToShowContainer(
                secondaryMessage: widget.emptyListMessage,
              ),
            );
          }
          return buildDoctorGrid(snapshot.data);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          Logger().w(error.toString());
        }
        return Center(
          child: NothingToShowContainer(
            iconPath: "assets/icons/network_error.svg",
            primaryMessage: "Something went wrong",
            secondaryMessage: "Unable to connect to Database",
          ),
        );
      },
    );
  }

  Widget buildDoctorGrid(List<String> doctorsId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: doctorsId.length,
      itemBuilder: (context, index) {
        return DoctorCard(
          doctorId: doctorsId[index],
          press: () {
            widget.onDoctorCardTapped.call(doctorsId[index]);
          },
        );
      },
    );
  }
}
