import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/models/Review.dart';
import 'package:block1/services/authentification/authentification_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

class DoctorDatabaseHelper {
  static const String DOCTORS_COLLECTION_NAME = "doctors";
  static const String REVIEWS_COLLECTOIN_NAME = "reviews";

  DoctorDatabaseHelper._privateConstructor();
  static DoctorDatabaseHelper _instance =
      DoctorDatabaseHelper._privateConstructor();
  factory DoctorDatabaseHelper() {
    return _instance;
  }
  FirebaseFirestore _firebaseFirestore;
  FirebaseFirestore get firestore {
    if (_firebaseFirestore == null) {
      _firebaseFirestore = FirebaseFirestore.instance;
    }
    return _firebaseFirestore;
  }

  Future<List<String>> searchInDoctors(String query,
      {DoctorType doctorType}) async {
    Query queryRef;
    if (doctorType == null) {
      queryRef = firestore.collection(DOCTORS_COLLECTION_NAME);
    } else {
      final doctorTypeStr = EnumToString.convertToString(doctorType);
      print(doctorTypeStr);
      queryRef = firestore
          .collection(DOCTORS_COLLECTION_NAME)
          .where(Doctor.DOCTOR_TYPE_KEY, isEqualTo: doctorTypeStr);
    }

    Set productsId = Set<String>();
    final querySearchInTags = await queryRef
        .where(Doctor.SEARCH_TAGS_KEY, arrayContains: query)
        .get();
    for (final doc in querySearchInTags.docs) {
      productsId.add(doc.id);
    }
    final queryRefDocs = await queryRef.get();
    for (final doc in queryRefDocs.docs) {
      final doctor = Doctor.fromMap(doc.data(), id: doc.id);
      if (doctor.title.toString().toLowerCase().contains(query) ||
          doctor.hospitalName.toString().toLowerCase().contains(query) ||
          doctor.description.toString().toLowerCase().contains(query) ||
          doctor.highlights.toString().toLowerCase().contains(query) ||
          doctor.qualification.toString().toLowerCase().contains(query) ||
          doctor.seller.toString().toLowerCase().contains(query)) {
        productsId.add(doctor.id);
      }
    }
    return productsId.toList();
  }

  Future<bool> addDoctorReview(String doctorId, Review review) async {
    final reviewesCollectionRef = firestore
        .collection(DOCTORS_COLLECTION_NAME)
        .doc(doctorId)
        .collection(REVIEWS_COLLECTOIN_NAME);
    final reviewDoc = reviewesCollectionRef.doc(review.reviewerUid);
    if ((await reviewDoc.get()).exists == false) {
      reviewDoc.set(review.toMap());
      return await addUsersRatingForDoctor(
        doctorId,
        review.rating,
      );
    } else {
      int oldRating = 0;
      oldRating = (await reviewDoc.get()).data()[Doctor.RATING_KEY];
      reviewDoc.update(review.toUpdateMap());
      return await addUsersRatingForDoctor(doctorId, review.rating,
          oldRating: oldRating);
    }
  }

  Future<bool> addUsersRatingForDoctor(String productId, int rating,
      {int oldRating}) async {
    final doctorDocRef =
        firestore.collection(DOCTORS_COLLECTION_NAME).doc(productId);
    final ratingsCount =
        (await doctorDocRef.collection(REVIEWS_COLLECTOIN_NAME).get())
            .docs
            .length;
    final doctorDoc = await doctorDocRef.get();
    final prevRating = doctorDoc.data()[Review.RATING_KEY];
    double newRating;
    if (oldRating == null) {
      newRating = (prevRating * (ratingsCount - 1) + rating) / ratingsCount;
    } else {
      newRating =
          (prevRating * (ratingsCount) + rating - oldRating) / ratingsCount;
    }
    final newRatingRounded = double.parse(newRating.toStringAsFixed(1));
    await doctorDocRef.update({Doctor.RATING_KEY: newRatingRounded});
    return true;
  }

  Future<Review> getDoctorReviewWithID(
      String doctorId, String reviewId) async {
    final reviewesCollectionRef = firestore
        .collection(DOCTORS_COLLECTION_NAME)
        .doc(doctorId)
        .collection(REVIEWS_COLLECTOIN_NAME);
    final reviewDoc = await reviewesCollectionRef.doc(reviewId).get();
    if (reviewDoc.exists) {
      return Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
    }
    return null;
  }

  Stream<List<Review>> getAllReviewsStreamForDoctorId(
      String doctorId) async* {
    final reviewesQuerySnapshot = firestore
        .collection(DOCTORS_COLLECTION_NAME)
        .doc(doctorId)
        .collection(REVIEWS_COLLECTOIN_NAME)
        .get()
        .asStream();
    await for (final querySnapshot in reviewesQuerySnapshot) {
      List<Review> reviews = List<Review>();
      for (final reviewDoc in querySnapshot.docs) {
        Review review = Review.fromMap(reviewDoc.data(), id: reviewDoc.id);
        reviews.add(review);
      }
      yield reviews;
    }
  }

  Future<Doctor> getDoctorWithID(String doctorId) async {
    final docSnapshot = await firestore
        .collection(DOCTORS_COLLECTION_NAME)
        .doc(doctorId)
        .get();

    if (docSnapshot.exists) {
      return Doctor.fromMap(docSnapshot.data(), id: docSnapshot.id);
    }
    return null;
  }

  Future<String> addUsersDoctor(Doctor doctor) async {
    String uid = AuthentificationService().currentUser.uid;
    final doctorMap = doctor.toMap();
    doctor.owner = uid;
    final productsCollectionReference =
        firestore.collection(DOCTORS_COLLECTION_NAME);
    final docRef = await productsCollectionReference.add(doctor.toMap());
    await docRef.update({
      Doctor.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
          [doctorMap[Doctor.DOCTOR_TYPE_KEY].toString().toLowerCase()])
    });
    return docRef.id;
  }

  Future<bool> deleteUserDoctor(String doctorId) async {
    final doctorsCollectionReference =
        firestore.collection(DOCTORS_COLLECTION_NAME);
    await doctorsCollectionReference.doc(doctorId).delete();
    return true;
  }

  Future<String> updateUsersDoctor(Doctor doctor) async {
    final doctorMap = doctor.toUpdateMap();
    final doctorsCollectionReference =
        firestore.collection(DOCTORS_COLLECTION_NAME);
    final docRef = doctorsCollectionReference.doc(doctor.id);
    await docRef.update(doctorMap);
    if (doctor.doctorType != null) {
      await docRef.update({
        Doctor.SEARCH_TAGS_KEY: FieldValue.arrayUnion(
            [doctorMap[Doctor.DOCTOR_TYPE_KEY].toString().toLowerCase()])
      });
    }
    return docRef.id;
  }

  Future<List<String>> getCategoryDoctorsList(DoctorType doctorType) async {
    final doctorsCollectionReference =
        firestore.collection(DOCTORS_COLLECTION_NAME);
    final queryResult = await doctorsCollectionReference
        .where(Doctor.DOCTOR_TYPE_KEY,
            isEqualTo: EnumToString.convertToString(doctorType))
        .get();
    List doctorsId = List<String>();
    for (final doctor in queryResult.docs) {
      final id = doctor.id;
      doctorsId.add(id);
    }
    return doctorsId;
  }

  Future<List<String>> get usersDoctorsList async {
    String uid = AuthentificationService().currentUser.uid;
    final doctorsCollectionReference =
        firestore.collection(DOCTORS_COLLECTION_NAME);
    final querySnapshot = await doctorsCollectionReference
        .where(Doctor.OWNER_KEY, isEqualTo: uid)
        .get();
    List usersDoctors = List<String>();
    querySnapshot.docs.forEach((doc) {
      usersDoctors.add(doc.id);
    });
    return usersDoctors;
  }

  Future<List<String>> get allDoctorsList async {
    final doctors = await firestore.collection(DOCTORS_COLLECTION_NAME).get();
    List doctorsId = List<String>();
    for (final doctor in doctors.docs) {
      final id = doctor.id;
      doctorsId.add(id);
    }
    return doctorsId;
  }

  Future<bool> updateDoctorsImages(
      String doctorId, List<String> imgUrl) async {
    final Doctor updateDoctor = Doctor(null, images: imgUrl);
    final docRef =
        firestore.collection(DOCTORS_COLLECTION_NAME).doc(doctorId);
    await docRef.update(updateDoctor.toUpdateMap());
    return true;
  }

  String getPathForDoctorImage(String id, int index) {
    String path = "doctors/images/$id";
    return path + "_$index";
  }
}
