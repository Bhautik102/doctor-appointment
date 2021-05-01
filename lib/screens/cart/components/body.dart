import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block1/components/default_button.dart';
import 'package:block1/components/nothingtoshow_container.dart';
import 'package:block1/components/doctor_short_detail_card.dart';
import 'package:block1/constants.dart';
import 'package:block1/models/CartItem.dart';
import 'package:block1/services/authentification/authentification_service.dart';

import 'package:block1/models/OrderedDoctor.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/cart/components/checkout_card.dart';
import 'package:block1/screens/doctor_details/doctor_details_screen.dart';
import 'package:block1/services/data_streams/cart_items_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/services/database/user_database_helper.dart';
import 'package:block1/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';

import '../../../utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final CartItemsStream cartItemsStream = CartItemsStream();
  PersistentBottomSheetController bottomSheetHandler;
  @override
  void initState() {
    super.initState();

    cartItemsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    cartItemsStream.dispose();
  }

  String _uid = AuthentificationService().currentUser.uid;
  List<List<String>> _orderedDoctorUid = [];
  List _ownerId = [];

  _get() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_uid)
        .collection("ordered_doctors")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _orderedDoctorUid.add([
          element["doctor_uid"],
          element["order_date"],
          element["patient_uid"],
          element["owner_uid"],
        ]);
      });
    });

    // print(_orderedDoctorUid);

    for (var i in _orderedDoctorUid){
      await FirebaseFirestore.instance.collection("doctors").doc(i[0].toString()).get().then((value) {
        _ownerId.add({"ownerId":value["owner"],"patientUid":i[2],"DoctorName":value["title"]});
      });

    }

    for (var i in _ownerId) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(i["ownerId"].toString())
          .collection("appointment")
          .doc("${i["ownerId"]}".toString().substring(0, 5) + "${i["title"]}")
          .set({
        "doctorName": i["title"].toString(),
        "patientUid": i["patientUid"],
        "ownerid": i["ownerId"]
      });
      print("fghfh");
    }
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseFirestore.instance.collection("doctors").doc("AiKvl80EJvi9VzyZYC25").get().then((value) {
    //   print(value["title"]);

    // });
    return SafeArea(
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
                    "Your Appointments",
                    style: headingStyle,
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.75,
                    child: Center(
                      child: buildCartItemsList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    cartItemsStream.reload();
    return Future<void>.value();
  }

  Widget buildCartItemsList() {
    return StreamBuilder<List<String>>(
      stream: cartItemsStream.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> cartItemsId = snapshot.data;
          if (cartItemsId.length == 0) {
            return Center(
              child: NothingToShowContainer(
                iconPath: "assets/icons/empty_cart.svg",
                secondaryMessage: "Your have no appointment",
              ),
            );
          }

          return Column(
            children: [
              DefaultButton(
                text: "Proceed to Confirm",
                press: () {
                  bottomSheetHandler = Scaffold.of(context).showBottomSheet(
                    (context) {
                      return CheckoutCard(
                        onCheckoutPressed: checkoutButtonCallback,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  physics: BouncingScrollPhysics(),
                  itemCount: cartItemsId.length,
                  itemBuilder: (context, index) {
                    if (index >= cartItemsId.length) {
                      return SizedBox(height: getProportionateScreenHeight(80));
                    }
                    return buildCartItemDismissible(
                        context, cartItemsId[index], index);
                  },
                ),
              ),
            ],
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

  Widget buildCartItemDismissible(
      BuildContext context, String cartItemId, int index) {
    return Dismissible(
      key: Key(cartItemId),
      direction: DismissDirection.startToEnd,
      dismissThresholds: {
        DismissDirection.startToEnd: 0.65,
      },
      background: buildDismissibleBackground(),
      child: buildCartItem(cartItemId, index),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirmation = await showConfirmationDialog(
            context,
            "Remove Doctor from Cart?",
          );
          if (confirmation) {
            if (direction == DismissDirection.startToEnd) {
              bool result = false;
              String snackbarMessage;
              try {
                result =
                    await UserDatabaseHelper().removeDoctorFromCart(cartItemId);
                if (result == true) {
                  snackbarMessage = "Doctor removed from cart successfully";
                  await refreshPage();
                } else {
                  throw "Coulnd't remove Doctor from cart due to unknown reason";
                }
              } on FirebaseException catch (e) {
                Logger().w("Firebase Exception: $e");
                snackbarMessage = "Something went wrong";
              } catch (e) {
                Logger().w("Unknown Exception: $e");
                snackbarMessage = "Something went wrong";
              } finally {
                Logger().i(snackbarMessage);
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snackbarMessage),
                  ),
                );
              }

              return result;
            }
          }
        }
        return false;
      },
      onDismissed: (direction) {},
    );
  }

  Widget buildCartItem(String cartItemId, int index) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 4,
        top: 4,
        right: 4,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: FutureBuilder<Doctor>(
        future: DoctorDatabaseHelper().getDoctorWithID(cartItemId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Doctor doctor = snapshot.data;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 8,
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
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: 2,
                //       vertical: 12,
                //     ),
                //     decoration: BoxDecoration(
                //       color: kTextColor.withOpacity(0.05),
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         InkWell(
                //           child: Icon(
                //             Icons.arrow_drop_up,
                //             color: kTextColor,
                //           ),
                //           onTap: () async {
                //             await arrowUpCallback(cartItemId);
                //           },
                //         ),
                //         SizedBox(height: 8),
                //         FutureBuilder<CartItem>(
                //           future: UserDatabaseHelper()
                //               .getCartItemFromId(cartItemId),
                //           builder: (context, snapshot) {
                //             int itemCount = 0;
                //             if (snapshot.hasData) {
                //               final cartItem = snapshot.data;
                //               itemCount = cartItem.itemCount;
                //             } else if (snapshot.hasError) {
                //               final error = snapshot.error.toString();
                //               Logger().e(error);
                //             }
                //             return Text(
                //               "$itemCount",
                //               style: TextStyle(
                //                 color: kPrimaryColor,
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w900,
                //               ),
                //             );
                //           },
                //         ),
                //         SizedBox(height: 8),
                //         InkWell(
                //           child: Icon(
                //             Icons.arrow_drop_down,
                //             color: kTextColor,
                //           ),
                //           onTap: () async {
                //             await arrowDownCallback(cartItemId);
                //           },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            Logger().w(error.toString());
            return Center(
              child: Text(
                error.toString(),
              ),
            );
          } else {
            return Center(
              child: Icon(
                Icons.error,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildDismissibleBackground() {
    return Container(
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkoutButtonCallback() async {
    shutBottomSheet();
    final confirmation = await showConfirmationDialog(
      context,
      "Are you sure to Confirm?",
    );
    if (confirmation == false) {
      return;
    }
    final orderFuture = UserDatabaseHelper().emptyCart();
    orderFuture.then((orderedDoctorsUid) async {
      if (orderedDoctorsUid != null) {
        // print(orderedDoctorsUid);

        String uid;
        setState(() {
          uid = AuthentificationService().current_user();
        });
        // print(uid);
        final dateTime = DateTime.now();
        final formatedDateTime =
            "${dateTime.day}-${dateTime.month}-${dateTime.year}";

        List<OrderedDoctor> orderedDoctors = orderedDoctorsUid
            .map((e) => OrderedDoctor(null,
                doctorUid: e, orderDate: formatedDateTime, patientUid: uid))
            .toList();
    // print(_ownerId);

        _get();

        bool addedDoctorsToMyDoctors = false;
        String snackbarmMessage;
        try {
          addedDoctorsToMyDoctors =
              await UserDatabaseHelper().addToMyOrders(orderedDoctors);
          if (addedDoctorsToMyDoctors) {
            snackbarmMessage = "Appoitment Taken Successfully";
          } else {
            throw "Could not Confirm Appointment due to unknown issue";
          }
        } on FirebaseException catch (e) {
          Logger().e(e.toString());
          snackbarmMessage = e.toString();
        } catch (e) {
          Logger().e(e.toString());
          snackbarmMessage = e.toString();
        } finally {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(snackbarmMessage ?? "Something went wrong"),
            ),
          );
        }
      } else {
        throw "Something went wrong while clearing cart";
      }
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            orderFuture,
            message: Text("Confirming Appointment"),
          );
        },
      );
    }).catchError((e) {
      Logger().e(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    });
    await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          orderFuture,
          message: Text("Confirming Appointment"),
        );
      },
    );
    await refreshPage();
  }

  void shutBottomSheet() {
    if (bottomSheetHandler != null) {
      bottomSheetHandler.close();
    }
  }

//   Future<void> arrowUpCallback(String cartItemId) async {
//     shutBottomSheet();
//     final future = UserDatabaseHelper().increaseCartItemCount(cartItemId);
//     future.then((status) async {
//       if (status) {
//         await refreshPage();
//       } else {
//         throw "Couldn't perform the operation due to some unknown issue";
//       }
//     }).catchError((e) {
//       Logger().e(e.toString());
//       Scaffold.of(context).showSnackBar(SnackBar(
//         content: Text("Something went wrong"),
//       ));
//     });
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return FutureProgressDialog(
//           future,
//           message: Text("Please wait"),
//         );
//       },
//     );
//   }

//   Future<void> arrowDownCallback(String cartItemId) async {
//     shutBottomSheet();
//     final future = UserDatabaseHelper().decreaseCartItemCount(cartItemId);
//     future.then((status) async {
//       if (status) {
//         await refreshPage();
//       } else {
//         throw "Couldn't perform the operation due to some unknown issue";
//       }
//     }).catchError((e) {
//       Logger().e(e.toString());

//       Scaffold.of(context).showSnackBar(SnackBar(
//         content: Text("Something went wrong"),
//       ));
//     });
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return FutureProgressDialog(
//           future,
//           message: Text("Please wait"),
//         );
//       },
//     );
//   }
}
