import 'package:block1/models/Model.dart';
import 'package:enum_to_string/enum_to_string.dart';

enum ReportType {
  Cancer,
  Corona,
  BloodPressure,
  
  HeartReport,
  Others,
}

class Report extends Model {
  static const String IMAGES_KEY = "images";
  static const String TITLE_KEY = "title";
    static const String LABORATORYNAME_KEY = "laboratoryName";

  

  // static const String SELLER_KEY = "seller";
  static const String OWNER_KEY = "owner";
  static const String REPORT_TYPE_KEY = "Report_type";
  static const String SEARCH_TAGS_KEY = "search_tags";

  List<String> images;
  String title;
  String laboratoryName;
  String owner;
  ReportType reportType;
  List<String> searchTags;

  Report(
    String id, {
    this.images,
    this.title,
    this.laboratoryName,
    this.reportType,
    // this.discountPrice,
    // this.originalPrice,
  
    this.owner,
    this.searchTags,
  }) : super(id);

  // int calculatePercentageDiscount() {
  //   int discount =
  //       (((originalPrice - discountPrice) * 100) / originalPrice).round();
  //   return discount;
  // }

  factory Report.fromMap(Map<String, dynamic> map, {String id}) {
    if (map[SEARCH_TAGS_KEY] == null) {
      map[SEARCH_TAGS_KEY] = List<String>();
    }
    return Report(
      id,
      images: map[IMAGES_KEY].cast<String>(),
      title: map[TITLE_KEY],
      laboratoryName: map[LABORATORYNAME_KEY],
      reportType:
          EnumToString.fromString(ReportType.values, map[REPORT_TYPE_KEY]),
      // discountPrice: map[DISCOUNT_PRICE_KEY],
      // originalPrice: map[ORIGINAL_PRICE_KEY],
  
      owner: map[OWNER_KEY],
      searchTags: map[SEARCH_TAGS_KEY].cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      IMAGES_KEY: images,
      TITLE_KEY: title,
      LABORATORYNAME_KEY: laboratoryName,
      REPORT_TYPE_KEY: EnumToString.convertToString(reportType),
      // DISCOUNT_PRICE_KEY: discountPrice,
      // ORIGINAL_PRICE_KEY: originalPrice,
 
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
    if(laboratoryName != null) map[LABORATORYNAME_KEY] = laboratoryName;


    if (reportType != null)
      map[REPORT_TYPE_KEY] = EnumToString.convertToString(reportType);
    if (owner != null) map[OWNER_KEY] = owner;
    if (searchTags != null) map[SEARCH_TAGS_KEY] = searchTags;

    return map;
  }
}
