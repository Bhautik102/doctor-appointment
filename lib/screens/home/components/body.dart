import 'package:block1/constants.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/cart/cart_screen.dart';
import 'package:block1/screens/category_doctors/category_doctors_screen.dart';
import 'package:block1/screens/doctor_details/doctor_details_screen.dart';
import 'package:block1/screens/my_doctors/my_doctors_screen.dart';
import 'package:block1/screens/search_result/search_result_screen.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:block1/services/data_streams/all_doctors_stream.dart';
import 'package:block1/services/data_streams/favourite_doctors_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import '../../../utils.dart';
import '../components/home_header.dart';
import 'doctor_type_box.dart';
import 'doctors_section.dart';

const String ICON_KEY = "icon";
const String TITLE_KEY = "title";
const String DOCTOR_TYPE_KEY = "doctor_type";

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final doctorCategories = <Map>[
    <String, dynamic>{
      ICON_KEY: "assets/icons/1.svg",
      TITLE_KEY: "General Clinic",
      DOCTOR_TYPE_KEY: DoctorType.General,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/2.svg",
      TITLE_KEY: "Dentist",
      DOCTOR_TYPE_KEY: DoctorType.Dentist,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/3.svg",
      TITLE_KEY: "Psychiatric",
      DOCTOR_TYPE_KEY: DoctorType.Psychiatric,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/4.svg",
      TITLE_KEY: "Children",
      DOCTOR_TYPE_KEY: DoctorType.Children,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/5.svg",
      TITLE_KEY: "HeartSurgen",
      DOCTOR_TYPE_KEY: DoctorType.HeartSurgen,
    },
    <String, dynamic>{
      ICON_KEY: "assets/icons/6.svg",
      TITLE_KEY: "Others",
      DOCTOR_TYPE_KEY: DoctorType.Others,
    },
  ];

  final FavouriteDoctorsStream favouriteDoctorsStream =
      FavouriteDoctorsStream();
  final AllDoctorsStream allDoctorsStream = AllDoctorsStream();

  @override
  void initState() {
    super.initState();
    favouriteDoctorsStream.init();
    allDoctorsStream.init();
  }

  @override
  void dispose() {
    favouriteDoctorsStream.dispose();
    allDoctorsStream.dispose();
    super.dispose();
  }

  String uid;
  String usertype;
  @override
  Widget build(BuildContext context) {
        
    setState(() {
      uid = AuthentificationService().current_user();
    });
    FirebaseFirestore.instance.collection("users").get().then((value) {
      value.docs.forEach((element) {
        if (element.data()["uid"] == uid) {
          setState(() {
            usertype = element.data()["userType"];
          });
          print(element.data()["success"]);
        }
      });
    });
    return SafeArea(
        
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
        
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.length <= 0) return;
                    List<String> searchedDoctorsId;
                    try {
                      searchedDoctorsId = await DoctorDatabaseHelper()
                          .searchInDoctors(query.toLowerCase());
                      if (searchedDoctorsId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultDoctorsId: searchedDoctorsId,
                              searchIn: "All Doctors",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Couldn't perform search due to some unknown reason";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$error"),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
                    bool allowed =
                        AuthentificationService().currentUserVerified;
                    if (!allowed) {
                      final reverify = await showConfirmationDialog(context,
                          "You haven't verified your email address. This action is only allowed for verified users.",
                          positiveResponse: "Resend verification email",
                          negativeResponse: "Go back");
                      if (reverify) {
                        final future = AuthentificationService()
                            .sendVerificationEmailToCurrentUser();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return FutureProgressDialog(
                              future,
                              message: Text("Resending verification email"),
                            );
                          },
                        );
                      }
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),

                if (usertype == "PATIENT")
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          ...List.generate(
                            doctorCategories.length,
                            (index) {
                              return DoctorTypeBox(
                                icon: doctorCategories[index][ICON_KEY],
                                title: doctorCategories[index][TITLE_KEY],
                                onPress: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDoctorsScreen(
                                        doctorType: doctorCategories[index]
                                            [DOCTOR_TYPE_KEY],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
// if(usertype=="DOCTOR")
//                   buildhospitalscreen(context),
                SizedBox(height: getProportionateScreenHeight(20)),


                if (usertype == "PATIENT")
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.5,
                    child: DoctorsSection(
                      sectionTitle: "Doctors You Like",
                      doctorsStreamController: favouriteDoctorsStream,
                      emptyListMessage: "Add Doctor to Favourites",
                      onDoctorCardTapped: onDoctorCardTapped,
                    ),
                  ),
                  
              
                SizedBox(height: getProportionateScreenHeight(20)),
                if (usertype == "PATIENT")
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.8,
                    child: DoctorsSection(
                      sectionTitle: "Explore All Doctors",
                      doctorsStreamController: allDoctorsStream,
                      emptyListMessage: "Looks like all Stores are closed",
                      onDoctorCardTapped: onDoctorCardTapped,
                    ),
                  ),

                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouriteDoctorsStream.reload();
    allDoctorsStream.reload();
    return Future<void>.value();
  }

  void onDoctorCardTapped(String doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctorId: doctorId),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
 
}
