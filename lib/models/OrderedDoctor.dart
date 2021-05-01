import 'Model.dart';

class OrderedDoctor extends Model {
  static const String DOCTOR_UID_KEY = "doctor_uid";
  static const String ORDER_DATE_KEY = "order_date";
  static const String PATIENT_UID_KEY   = "patient_uid";
  static const String DOCTOR_OWNER_KEY = "owner_key";

  String doctorUid;
  String orderDate;
  String patientUid;
  String ownerid;
  OrderedDoctor(
    String id, {
    this.doctorUid,
    this.orderDate, this.patientUid,this.ownerid
  }) : super(id);

  factory OrderedDoctor.fromMap(Map<String, dynamic> map, {String id}) {
    return OrderedDoctor(
      id,
      doctorUid: map[DOCTOR_UID_KEY],
      orderDate: map[ORDER_DATE_KEY],
      patientUid:map[PATIENT_UID_KEY],
      ownerid: map[DOCTOR_OWNER_KEY]
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DOCTOR_UID_KEY: doctorUid,
      ORDER_DATE_KEY: orderDate,
      PATIENT_UID_KEY: patientUid,
      DOCTOR_OWNER_KEY: ownerid
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (doctorUid != null) map[DOCTOR_UID_KEY] = doctorUid;
    if (orderDate != null) map[ORDER_DATE_KEY] = orderDate;
    if(patientUid != null) map[PATIENT_UID_KEY] = patientUid;
    if(ownerid != null) map[DOCTOR_OWNER_KEY] =ownerid; 
    return map;
  }
}
