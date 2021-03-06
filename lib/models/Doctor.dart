import 'package:block1/models/Model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum DoctorType {
  General,
  Dentist,
  Psychiatric,
  Children,
  HeartSurgen,
  Others,
}

class Doctor extends Model {
  static const String IMAGES_KEY = "images";
  static const String TITLE_KEY = "title";
    static const String HOSPITALNAME_KEY = "hospitalName";

  static const String VARIANT_KEY = "qualification";
  // static const String DISCOUNT_PRICE_KEY = "discount_price";
  // static const String ORIGINAL_PRICE_KEY = "original_price";
  static const String RATING_KEY = "rating";
  static const String HIGHLIGHTS_KEY = "highlights";
  static const String DESCRIPTION_KEY = "description";
  static const String SELLER_KEY = "seller";
  static const String OWNER_KEY = "owner";
  static const String DOCTOR_TYPE_KEY = "doctor_type";
  static const String SEARCH_TAGS_KEY = "search_tags";

  List<String> images;
  String title;
  String qualification;
  String hospitalName;
  // num discountPrice;
  // num originalPrice;
  num rating;
  String highlights;
  String description;
  String seller;
  bool favourite;
  String owner;
  DoctorType doctorType;
  List<String> searchTags;

  Doctor(
    String id, {
    this.images,
    this.title,
    this.hospitalName,
    this.qualification,
    this.doctorType,
    // this.discountPrice,
    // this.originalPrice,
    this.rating = 0.0,
    this.highlights,
    this.description,
    this.seller,
    this.owner,
    this.searchTags,
  }) : super(id);

  // int calculatePercentageDiscount() {
  //   int discount =
  //       (((originalPrice - discountPrice) * 100) / originalPrice).round();
  //   return discount;
  // }

  factory Doctor.fromMap(Map<String, dynamic> map, {String id}) {
    if (map[SEARCH_TAGS_KEY] == null) {
      map[SEARCH_TAGS_KEY] = List<String>();
    }
    return Doctor(
      id,
      images: map[IMAGES_KEY].cast<String>(),
      title: map[TITLE_KEY],
      hospitalName: map[HOSPITALNAME_KEY],
      qualification: map[VARIANT_KEY],
      doctorType:
          EnumToString.fromString(DoctorType.values, map[DOCTOR_TYPE_KEY]),
      // discountPrice: map[DISCOUNT_PRICE_KEY],
      // originalPrice: map[ORIGINAL_PRICE_KEY],
      rating: map[RATING_KEY],
      highlights: map[HIGHLIGHTS_KEY],
      description: map[DESCRIPTION_KEY],
      seller: map[SELLER_KEY],
      owner: map[OWNER_KEY],
      searchTags: map[SEARCH_TAGS_KEY].cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      IMAGES_KEY: images,
      TITLE_KEY: title,
      HOSPITALNAME_KEY: hospitalName,
      VARIANT_KEY: qualification,
      DOCTOR_TYPE_KEY: EnumToString.convertToString(doctorType),
      // DISCOUNT_PRICE_KEY: discountPrice,
      // ORIGINAL_PRICE_KEY: originalPrice,
      RATING_KEY: rating,
      HIGHLIGHTS_KEY: highlights,
      DESCRIPTION_KEY: description,
      SELLER_KEY: seller,
      OWNER_KEY: owner,
      SEARCH_TAGS_KEY: searchTags,
    };

    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (images != null) map[IMAGES_KEY] = images;
    if (title != null) map[TITLE_KEY] = title;
    if(hospitalName != null) map[HOSPITALNAME_KEY] = hospitalName;
    if (qualification != null) map[VARIANT_KEY] = qualification;
    // if (discountPrice != null) map[DISCOUNT_PRICE_KEY] = discountPrice;
    // if (originalPrice != null) map[ORIGINAL_PRICE_KEY] = originalPrice;
    if (rating != null) map[RATING_KEY] = rating;
    if (highlights != null) map[HIGHLIGHTS_KEY] = highlights;
    if (description != null) map[DESCRIPTION_KEY] = description;
    if (seller != null) map[SELLER_KEY] = seller;
    if (doctorType != null)
      map[DOCTOR_TYPE_KEY] = EnumToString.convertToString(doctorType);
    if (owner != null) map[OWNER_KEY] = owner;
    if (searchTags != null) map[SEARCH_TAGS_KEY] = searchTags;

    return map;
  }
}
