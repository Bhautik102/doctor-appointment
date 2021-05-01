import 'package:block1/components/top_rounded_container.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/models/Review.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:date_format/date_format.dart';

import '../../../constants.dart';
import '../../../size_config.dart';
import 'review_box.dart';

class DateSelectSection extends StatefulWidget {
  const DateSelectSection({
    Key key,
    @required this.doctor,
  }) : super(key: key);

  final Doctor doctor;

  @override
  _DateSelectSectionState createState() => _DateSelectSectionState();
}

class _DateSelectSectionState extends State<DateSelectSection> {

    double _height;
  double _width;

  String _setTime, _setDate;

  String _hour, _minute, _time;

  String dateTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  void _selectDate() {
    final Future<DateTime> picked =  showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked as DateTime;
        _dateController.text = DateFormat.yMd().format(selectedDate);
      });
  }

  void _selectTime() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState() {
    _dateController.text = DateFormat.yMd().format(DateTime.now());

    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    super.initState();
  }
  @override

  Widget build(BuildContext context) {
        _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
        dateTime = DateFormat.yMd().format(DateTime.now());

    return SizedBox(
      height: getProportionateScreenHeight(400),
      child: Container(
        width: _width,
        height: _height,
        child: Stack(
          children: [
            TopRoundedContainer(
              child: Column(
                children: [
                  Text(
                    "Select Date And Time",
                    style: TextStyle(
                      fontSize: 21,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  Expanded(
                    
              child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    'Choose Date',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        
                        ),
                  ),
                  
                  InkWell(
                    onTap: () {
                      _selectDate();
                    },
                    
                    child: Container(
                      width: _width / 1,
                      height: _height / 5000,
                      margin: EdgeInsets.only(top: 40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      
                      child: TextFormField(
                        style: TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _dateController,
                        onSaved: (String val) {
                          _setDate = val;
                        },
                        
                        decoration: InputDecoration(
                            disabledBorder:
                                UnderlineInputBorder(borderSide: BorderSide.none),
                            // labelText: 'Time',
                            contentPadding: EdgeInsets.only(top: 0.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ]
                  ),
                  ),
                                    SizedBox(height: getProportionateScreenHeight(20)),

                  Expanded(child: 
                  Column(
                children: <Widget>[
                  Text(
                    'Choose Time',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5),
                  ),
                  InkWell(
                    onTap: () {
                      _selectTime();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 40),
                      width: _width / 1,
                      height: _height / 5000,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: TextFormField(
                        style: TextStyle(fontSize: 40),
                        textAlign: TextAlign.center,
                        onSaved: (String val) {
                          _setTime = val;
                        },
                        enabled: false,
                        keyboardType: TextInputType.text,
                        controller: _timeController,
                        decoration: InputDecoration(
                            disabledBorder:
                                UnderlineInputBorder(borderSide: BorderSide.none),
                            // labelText: 'Time',
                            contentPadding: EdgeInsets.all(5)),
                      ),
                    ),
                  ),
                ],
              ),
                  )
               
            ]
                
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

