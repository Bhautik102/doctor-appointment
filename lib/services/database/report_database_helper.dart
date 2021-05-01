// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:block1/models/report.dart';
// import 'package:block1/services/authentification/authentification_service.dart';
// import 'package:enum_to_string/enum_to_string.dart';

// class ReportDatabaseHelper {
//   static const String REPORTS_COLLECTION_NAME = "reports";
//   // static const String REVIEWS_COLLECTOIN_NAME = "reviews";

//   ReportDatabaseHelper._privateConstructor();
//   static ReportDatabaseHelper _instance =
//       ReportDatabaseHelper._privateConstructor();
//   factory ReportDatabaseHelper() {
//     return _instance;
//   }
//   FirebaseFirestore _firebaseFirestore;
//   FirebaseFirestore get firestore {
//     if (_firebaseFirestore == null) {
//       _firebaseFirestore = FirebaseFirestore.instance;
//     }
//     return _firebaseFirestore;
//   }




//   Future<List<String>> searchInReports(String query,
//       {ReportType reportType}) async {
//     Query queryRef;
//     if (reportType == null) {
//       queryRef = firestore.collection(REPORTS_COLLECTION_NAME);
//     } else {
//       final reportTypeStr = EnumToString.convertToString(reportType);
//       print(reportTypeStr);
//       queryRef = firestore
//           .collection(REPORTS_COLLECTION_NAME)
//           .where(Report.REPORT_TYPE_KEY, isEqualTo: reportTypeStr);
//     }

//     Set reportsId = Set<String>();
//     final querySearchInTags = await queryRef
//         .where(Report.SEARCH_TAGS_KEY, arrayContains: query)
//         .get();
//     for (final doc in querySearchInTags.docs) {
//       reportsId.add(doc.id);
//     }
//     final queryRefDocs = await queryRef.get();
//     for (final doc in queryRefDocs.docs) {
//       final report = Report.fromMap(doc.data(), id: doc.id);
//       if (report.title.toString().toLowerCase().contains(query) ||
//           report.laboratoryName.toString().toLowerCase().contains(query) )
       
//          {
//         reportsId.add(report.id);
//       }
      
//     }
//     return reportsId.toList();
//   }

//   Future<Report> getReportWithID(String reportId) async {
//     final docSnapshot = await firestore
//         .collection(REPORTS_COLLECTION_NAME)
//         .doc(reportId)
//         .get();

//     if (docSnapshot.exists) {
//       return Report.fromMap(docSnapshot.data(), id: docSnapshot.id);
//     }
//     return null;
//   }

//   Future<String> addUsersReport(Report report) async {
//     String uid = AuthentificationService().currentUser.uid;
//     final reportMap = report.toMap();
//     report.owner = uid;
//     final reportsCollectionReference =
//         firestore.collection(REPORTS_COLLECTION_NAME);
//     final docRef = await reportsCollectionReference.add(report.toMap());
//     await docRef.update({
//       Report.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
//           [reportMap[Report.REPORT_TYPE_KEY].toString().toLowerCase()])
//     });
//     return docRef.id;
//   }

//   Future<bool> deleteUserReport(String reportId) async {
//     final reportsCollectionReference =
//         firestore.collection(REPORTS_COLLECTION_NAME);
//     await reportsCollectionReference.doc(reportId).delete();
//     return true;
//   }

//   Future<String> updateUsersReport(Report report) async {
//     final reportMap = report.toUpdateMap();
//     final reportsCollectionReference =
//         firestore.collection(REPORTS_COLLECTION_NAME);
//     final docRef = reportsCollectionReference.doc(report.id);
//     await docRef.update(reportMap);
//     if (report.reportType != null) {
//       await docRef.update({
//         Report.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
//             [reportMap[Report.REPORT_TYPE_KEY].toString().toLowerCase()])
//       });
//     }
//     return docRef.id;
//   }

//   Future<List<String>> getCategoryReportsList(ReportType reportType) async {
//     final reportsCollectionReference =
//         firestore.collection(REPORTS_COLLECTION_NAME);
//     final queryResult = await reportsCollectionReference
//         .where(Report.REPORT_TYPE_KEY,
//             isEqualTo: EnumToString.convertToString(reportType))
//         .get();
//     List reportsId = List<String>();
//     for (final report in queryResult.docs) {
//       final id = report.id;
//       reportsId.add(id);
//     }
//     return reportsId;
//   }

//   Future<List<String>> get usersReportsList async {
//     String uid = AuthentificationService().currentUser.uid;
//     final reportsCollectionReference =
//         firestore.collection(REPORTS_COLLECTION_NAME);
//     final querySnapshot = await reportsCollectionReference
//         .where(Report.OWNER_KEY, isEqualTo: uid)
//         .get();
//     List usersReports = List<String>();
//     querySnapshot.docs.forEach((doc) {
//       usersReports.add(doc.id);
//     });
//     return usersReports;
//   }

//   Future<List<String>> get allReportsList async {
//     final reports = await firestore.collection(REPORTS_COLLECTION_NAME).get();
//     List reportsId = List<String>();
//     for (final report in reports.docs) {
//       final id = report.id;
//       reportsId.add(id);
//     }
//     return reportsId;
//   }

//   Future<bool> updateReportsImages(
//       String reportId, List<String> imgUrl) async {
//     final Report updateReport = Report(null, images: imgUrl);
//     final docRef =
//         firestore.collection(REPORTS_COLLECTION_NAME).doc(reportId);
//     await docRef.update(updateReport.toUpdateMap());
//     return true;
//   }

//   String getPathForReportImage(String id, int index) {
//     String path = "reports/images/$id";
//     return path + "_$index";
//   }
// }
