import 'package:block1/components/nothingtoshow_container.dart';
import 'package:block1/components/doctor_short_detail_card.dart';
import 'package:block1/constants.dart';
import 'package:block1/models/OrderedDoctor.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/models/Review.dart';
import 'package:block1/screens/my_appointments/components/product_review_dialog.dart';
import 'package:block1/screens/doctor_details/doctor_details_screen.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:block1/services/data_streams/ordered_doctors_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/services/database/user_database_helper.dart';
import 'package:block1/size_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final OrderedDoctorsStream orderedDoctorsStream = OrderedDoctorsStream();

  @override
  void initState() {
    super.initState();
    orderedDoctorsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    orderedDoctorsStream.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(color: Colors.blueGrey[800]),
      
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshPage,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(screenPadding)),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Text(
                      "Your Appoitments",
                      style: headingStyle,
                    ),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.75,
                      child: buildOrderedDoctorsList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    orderedDoctorsStream.reload();
    return Future<void>.value();
  }

  Widget buildOrderedDoctorsList() {
    return StreamBuilder<List<String>>(
      stream: orderedDoctorsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final orderedDoctorsIds = snapshot.data;
          if (orderedDoctorsIds.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_bag.svg",
                secondaryMessage: "Take Appointment something to show here",
              ),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: orderedDoctorsIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<OrderedDoctor>(
                future: UserDatabaseHelper()
                    .getOrderedDoctorFromId(orderedDoctorsIds[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final orderedDoctor = snapshot.data;
                    return buildOrderedDoctorItem(orderedDoctor);
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    Logger().e(error);
                  }
                  return Icon(
                    Icons.error,
                    size: 60,
                    color: kTextColor,
                  );
                },
              );
            },
          );
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

  Widget buildOrderedDoctorItem(OrderedDoctor orderedDoctor) {
    return FutureBuilder<Doctor>(
      future:
          DoctorDatabaseHelper().getDoctorWithID(orderedDoctor.doctorUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final doctor = snapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: kTextColor.withOpacity(0.12),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "Taken on:  ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: orderedDoctor.orderDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(
                        color: kTextColor.withOpacity(0.15),
                      ),
                    ),
                  ),
                  child: DoctorShortDetailCard(
                    doctorId: doctor.id,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailsScreen(
                            doctorId: doctor.id,
                          ),
                        ),
                      ).then((_) async {
                        await refreshPage();
                      });
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: FlatButton(
                    onPressed: () async {
                      String currentUserUid =
                          AuthentificationService().currentUser.uid;
                      Review prevReview;
                      try {
                        prevReview = await DoctorDatabaseHelper()
                            .getDoctorReviewWithID(doctor.id, currentUserUid);
                      } on FirebaseException catch (e) {
                        Logger().w("Firebase Exception: $e");
                      } catch (e) {
                        Logger().w("Unknown Exception: $e");
                      } finally {
                        if (prevReview == null) {
                          prevReview = Review(
                            currentUserUid,
                            reviewerUid: currentUserUid,
                          );
                        }
                      }

                      final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return ProductReviewDialog(
                            review: prevReview,
                          );
                        },
                      );
                      if (result is Review) {
                        bool reviewAdded = false;
                        String snackbarMessage;
                        try {
                          reviewAdded = await DoctorDatabaseHelper()
                              .addDoctorReview(doctor.id, result);
                          if (reviewAdded == true) {
                            snackbarMessage =
                                "Doctor review added successfully";
                          } else {
                            throw "Coulnd't add doctor review due to unknown reason";
                          }
                        } on FirebaseException catch (e) {
                          Logger().w("Firebase Exception: $e");
                          snackbarMessage = e.toString();
                        } catch (e) {
                          Logger().w("Unknown Exception: $e");
                          snackbarMessage = e.toString();
                        } finally {
                          Logger().i(snackbarMessage);
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text(snackbarMessage),
                            ),
                          );
                        }
                      }
                      await refreshPage();
                    },
                    child: Text(
                      "Give Doctor Review",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          final error = snapshot.error.toString();
          Logger().e(error);
        }
        return Icon(
          Icons.error,
          size: 60,
          color: kTextColor,
        );
      },
    );
  }
}
