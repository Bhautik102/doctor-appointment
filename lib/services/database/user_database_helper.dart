import 'package:block1/screens/sign_up/components/usertype.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block1/models/Address.dart';
import 'package:block1/models/CartItem.dart';
import 'package:block1/models/OrderedDoctor.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/models/report.dart';
import 'package:enum_to_string/enum_to_string.dart';

class UserDatabaseHelper {
  static const String USERS_COLLECTION_NAME = "users";
  static const String ADDRESSES_COLLECTION_NAME = "addresses";
  static const String CART_COLLECTION_NAME = "cart";
  static const String ORDERED_DOCTORS_COLLECTION_NAME = "ordered_doctors";

  static const String PHONE_KEY = 'phone';
  static const String DP_KEY = "display_picture";
  static const String FAV_DOCTORS_KEY = "favourite_doctors";
  static const String REPORTS_COLLECTION_NAME = "reports";

  UserDatabaseHelper._privateConstructor();
  static UserDatabaseHelper _instance =
      UserDatabaseHelper._privateConstructor();
      
  factory UserDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<void> createNewUser(String uid,String userType,String displayName) async {
    await firestore.collection(USERS_COLLECTION_NAME).doc(uid).set({
      DP_KEY: null,
      PHONE_KEY: null,
      FAV_DOCTORS_KEY: List<String>(),
      "uid":uid,
      "userType":userType,
      "hospitalName":displayName
      
    });
  }

  Future<void> deleteCurrentUserData() async {
    final uid = AuthentificationService().currentUser.uid;
    final docRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final cartCollectionRef = docRef.collection(CART_COLLECTION_NAME);
    final addressCollectionRef = docRef.collection(ADDRESSES_COLLECTION_NAME);
    final ordersCollectionRef =
        docRef.collection(ORDERED_DOCTORS_COLLECTION_NAME);

    final cartDocs = await cartCollectionRef.get();
    for (final cartDoc in cartDocs.docs) {
      await cartCollectionRef.doc(cartDoc.id).delete();
    }
    final addressesDocs = await addressCollectionRef.get();
    for (final addressDoc in addressesDocs.docs) {
      await addressCollectionRef.doc(addressDoc.id).delete();
    }
    final ordersDoc = await ordersCollectionRef.get();
    for (final orderDoc in ordersDoc.docs) {
      await ordersCollectionRef.doc(orderDoc.id).delete();
    }

    await docRef.delete();
  }

  Future<bool> isDoctorFavourite(String doctorId) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final favList = userDocData[FAV_DOCTORS_KEY].cast<String>();
    if (favList.contains(doctorId)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> get usersFavouriteDoctorsList async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    final userDocData = (await userDocSnapshot.get()).data();
    final favList = userDocData[FAV_DOCTORS_KEY];
    return favList;
  }

  Future<bool> switchDoctorFavouriteStatus(
      String doctorId, bool newState) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);

    if (newState == true) {
      userDocSnapshot.update({
        FAV_DOCTORS_KEY: FieldValue.arrayUnion([doctorId])
      });
    } else {
      userDocSnapshot.update({
        FAV_DOCTORS_KEY: FieldValue.arrayRemove([doctorId])
      });
    }
    return true;
  }

  Future<List<String>> get addressesList async {
    String uid = AuthentificationService().currentUser.uid;
    final snapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .get();
    final addresses = List<String>();
    snapshot.docs.forEach((doc) {
      addresses.add(doc.id);
    });

    return addresses;
  }

  Future<Address> getAddressFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final doc = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(id)
        .get();
    final address = Address.fromMap(doc.data(), id: doc.id);
    return address;
  }

  Future<bool> addAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressesCollectionReference = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME);
    await addressesCollectionReference.add(address.toMap());
    return true;
  }

  Future<bool> deleteAddressForCurrentUser(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(id);
    await addressDocReference.delete();
    return true;
  }

  Future<bool> updateAddressForCurrentUser(Address address) async {
    String uid = AuthentificationService().currentUser.uid;
    final addressDocReference = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ADDRESSES_COLLECTION_NAME)
        .doc(address.id);
    await addressDocReference.update(address.toMap());
    return true;
  }

  Future<CartItem> getCartItemFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(id);
    final docSnapshot = await docRef.get();
    final cartItem = CartItem.fromMap(docSnapshot.data(), id: docSnapshot.id);
    return cartItem;
  }

  Future<bool> addDoctorToCart(String doctorId) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    final docRef = cartCollectionRef.doc(doctorId);
    final docSnapshot = await docRef.get();
    bool alreadyPresent = docSnapshot.exists;
    if (alreadyPresent == false) {
      docRef.set(CartItem(itemCount: 1).toMap());
    } else {
      docRef.update({CartItem.ITEM_COUNT_KEY: FieldValue.increment(1)});
    }
    return true;
  }

  Future<List<String>> emptyCart() async {
    String uid = AuthentificationService().currentUser.uid;
    final cartItems = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME)
        .get();
    List orderedDoctorsUid = List<String>();
    for (final doc in cartItems.docs) {
      orderedDoctorsUid.add(doc.id);
      await doc.reference.delete();
    }
    return orderedDoctorsUid;
  }

  

  Future<bool> removeDoctorFromCart(String cartItemID) async {
    String uid = AuthentificationService().currentUser.uid;
    final cartCollectionReference = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME);
    await cartCollectionReference.doc(cartItemID).delete();
    return true;
  }



 

  Future<List<String>> get allCartItemsList async {
    String uid = AuthentificationService().currentUser.uid;
    final querySnapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(CART_COLLECTION_NAME)
        .get();
    List itemsId = List<String>();
    for (final item in querySnapshot.docs) {
      itemsId.add(item.id);
    }
    return itemsId;
  }

  Future<List<String>> get orderedDoctorsList async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedDoctorsSnapshot = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ORDERED_DOCTORS_COLLECTION_NAME)
        .get();
    List orderedDoctorsId = List<String>();
    for (final doc in orderedDoctorsSnapshot.docs) {
      orderedDoctorsId.add(doc.id);
    }
    return orderedDoctorsId;
  }

  Future<bool> addToMyOrders(List<OrderedDoctor> orders) async {
    String uid = AuthentificationService().currentUser.uid;
    final orderedDoctorsCollectionRef = firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ORDERED_DOCTORS_COLLECTION_NAME);
    for (final order in orders) {
      await orderedDoctorsCollectionRef.add(order.toMap());
    }
    return true;
  }

  Future<OrderedDoctor> getOrderedDoctorFromId(String id) async {
    String uid = AuthentificationService().currentUser.uid;
    final doc = await firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .collection(ORDERED_DOCTORS_COLLECTION_NAME)
        .doc(id)
        .get();
    final orderedDoctor = OrderedDoctor.fromMap(doc.data(), id: doc.id);
    print('cbdshfgregbkurahruihrjtkhtkjsrgsdjktlgdutiagrieljeewrerrggr');
    print(doc.data());
    return orderedDoctor;

    
  }

//   static  matchPatients()async{
//     String uid = AuthentificationService().currentUser.uid;
//     String _gettedOwnerId; 
//     // FirebaseFirestore.instance.collection("doctors").get().then((value) {
//     //   value.docs.forEach((element) {
//     //        if(element.id=="pfO3vEDBghyIpTlReUZH"){
             
//     //          _gettedOwnerId=element["owner"];
//     //        }
//     //   });
//     // });

// String ownerMatched;
//     FirebaseFirestore.instance.collection("users").get().then((value) => value.docs.forEach((element) {
//       if(element.id==_gettedOwnerId){
//         ownerMatched=element.id;
//         print(element["hospitalName"]);
        
//       }
//     }));
//     String usersData;
//     // FirebaseFirestore.instance.collection("users").doc(ownerMatched).get().then((value) => print(value["hospitalName"]));
//      FirebaseFirestore.instance.collection("users").get().then((value) {
//        value.docs.forEach((element) { 
//          if(element["uid"]==uid){
//            usersData=element["hospitalName"];
//          }
//        });
//      });
//     FirebaseFirestore.instance.collection("users").doc("aLJcbVkSzQQ2elIBt7IGpmJR21a2").update({"selectedPatient":usersData}) ;
//   }



  
  



  Stream<DocumentSnapshot> get currentUserDataStream {
    String uid = AuthentificationService().currentUser.uid;
    return firestore
        .collection(USERS_COLLECTION_NAME)
        .doc(uid)
        .get()
        .asStream();
  }

  Future<bool> updatePhoneForCurrentUser(String phone) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update({PHONE_KEY: phone});
    return true;
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = AuthentificationService().currentUser.uid;
    return "user/display_picture/$currentUserUid";
  }

  Future<bool> uploadDisplayPictureForCurrentUser(String url) async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {DP_KEY: url},
    );
    return true;
  }

  Future<bool> removeDisplayPictureForCurrentUser() async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid);
    await userDocSnapshot.update(
      {
        DP_KEY: FieldValue.delete(),
      },
    );
    return true;
  }

  Future<String> get displayPictureForCurrentUser async {
    String uid = AuthentificationService().currentUser.uid;
    final userDocSnapshot =
        await firestore.collection(USERS_COLLECTION_NAME).doc(uid).get();
    return userDocSnapshot.data()[DP_KEY];
  }


//  Future<List<String>> searchInDoctors(String query,
//       {DoctorType doctorType}) async {
//     Query queryRef;
//     if (doctorType == null) {
//       queryRef = firestore.collection(DOCTORS_COLLECTION_NAME);
//     } else {
//       final doctorTypeStr = EnumToString.convertToString(doctorType);
//       print(doctorTypeStr);
//       queryRef = firestore
//           .collection(DOCTORS_COLLECTION_NAME)
//           .where(Doctor.DOCTOR_TYPE_KEY, isEqualTo: doctorTypeStr);
//     }

  Future<List<String>> searchInReports(String query,
      {ReportType reportType}) async {
    Query queryRef;
        String uid = AuthentificationService().currentUser.uid;

    if (reportType == null) {
      queryRef = firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    } else {
      final reportTypeStr = EnumToString.convertToString(reportType);
      print(reportTypeStr);
      queryRef = firestore
          .collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME)
          .where(Report.REPORT_TYPE_KEY, isEqualTo: reportTypeStr);
    }

    Set reportsId = Set<String>();
    final querySearchInTags = await queryRef
        .where(Report.SEARCH_TAGS_KEY, arrayContains: query)
        .get();
    for (final doc in querySearchInTags.docs) {
      reportsId.add(doc.id);
    }
    final queryRefDocs = await queryRef.get();
    for (final doc in queryRefDocs.docs) {
      final report = Report.fromMap(doc.data(), id: doc.id);
      if (report.title.toString().toLowerCase().contains(query) ||
          report.laboratoryName.toString().toLowerCase().contains(query) )
       
         {
        reportsId.add(report.id);
      }
      
    }
    return reportsId.toList();
  }

  Future<Report> getReportWithID(String reportId) async {
        String uid = AuthentificationService().currentUser.uid;

    final docSnapshot = await firestore
        .collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME)
        .doc(reportId)
        .get();

    if (docSnapshot.exists) {
      return Report.fromMap(docSnapshot.data(), id: docSnapshot.id);
    }
    return null;
  }




  Future<String> addUsersReport(Report report) async {
    String uid = AuthentificationService().currentUser.uid;
    final reportMap = report.toMap();
    report.owner = uid;
    final reportsCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    final docRef = await reportsCollectionReference.add(report.toMap());
    await docRef.update({
      Report.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
          [reportMap[Report.REPORT_TYPE_KEY].toString().toLowerCase()])
    });
    return docRef.id;
  }

  Future<bool> deleteUserReport(String reportId) async {
        String uid = AuthentificationService().currentUser.uid;

    final reportsCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    await reportsCollectionReference.doc(reportId).delete();
    return true;
  }

  Future<String> updateUsersReport(Report report) async {
        String uid = AuthentificationService().currentUser.uid;

    final reportMap = report.toUpdateMap();
    final reportsCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    final docRef = reportsCollectionReference.doc(report.id);
    await docRef.update(reportMap);
    if (report.reportType != null) {
      await docRef.update({
        Report.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
            [reportMap[Report.REPORT_TYPE_KEY].toString().toLowerCase()])
      });
    }
    return docRef.id;
  }

  Future<List<String>> getCategoryReportsList(ReportType reportType) async {
        String uid = AuthentificationService().currentUser.uid;

    final reportsCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    final queryResult = await reportsCollectionReference
        .where(Report.REPORT_TYPE_KEY,
            isEqualTo: EnumToString.convertToString(reportType))
        .get();
    List reportsId = List<String>();
    for (final report in queryResult.docs) {
      final id = report.id;
      reportsId.add(id);
    }
    return reportsId;
  }

  Future<List<String>> get usersReportsList async {
    String uid = AuthentificationService().currentUser.uid;
    final reportsCollectionReference =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME);
    final querySnapshot = await reportsCollectionReference
        .where(Report.OWNER_KEY, isEqualTo: uid)
        .get();
    List usersReports = List<String>();
    querySnapshot.docs.forEach((doc) {
      usersReports.add(doc.id);
    });
    return usersReports;
  }

  Future<List<String>> get allReportsList async {
        String uid = AuthentificationService().currentUser.uid;

    final reports = await firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME).get();
    List reportsId = List<String>();
    for (final report in reports.docs) {
      final id = report.id;
      reportsId.add(id);
    }
    return reportsId;
  }

  Future<bool> updateReportsImages(
      String reportId, List<String> imgUrl) async {
            String uid = AuthentificationService().currentUser.uid;

    final Report updateReport = Report(null, images: imgUrl);
    final docRef =
        firestore.collection(USERS_COLLECTION_NAME).doc(uid).collection(REPORTS_COLLECTION_NAME).doc(reportId);
    await docRef.update(updateReport.toUpdateMap());
    return true;
  }

  String getPathForReportImage(String id, int index) {
    String path = "reports/images/$id";
    return path + "_$index";
  }
}
