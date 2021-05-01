import 'package:flutter/material.dart';

class DoctorActions extends ChangeNotifier {
  bool _doctorFavStatus = false;

  bool get doctorFavStatus {
    return _doctorFavStatus;
  }

  set initialDoctorFavStatus(bool status) {
    _doctorFavStatus = status;
  }

  set doctorFavStatus(bool status) {
    _doctorFavStatus = status;
    notifyListeners();
  }

  void switchDoctorFavStatus() {
    _doctorFavStatus = !_doctorFavStatus;
    notifyListeners();
  }
}
