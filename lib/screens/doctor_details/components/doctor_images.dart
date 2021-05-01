import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/doctor_details/provider_models/DoctorImageSwiper.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom_image_updated/pinch_zoom_image_updated.dart';
import 'package:provider/provider.dart';
import 'package:swipedetector/swipedetector.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class DoctorImages extends StatelessWidget {
  const DoctorImages({
    Key key,
    @required this.doctor,
  }) : super(key: key);

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DoctorImageSwiper(),
      child: Consumer<DoctorImageSwiper>(
        builder: (context, doctorImagesSwiper, child) {
          return Column(
            children: [
              SwipeDetector(
                onSwipeLeft: () {
                  doctorImagesSwiper.currentImageIndex++;
                  doctorImagesSwiper.currentImageIndex %=
                      doctor.images.length;
                },
                onSwipeRight: () {
                  doctorImagesSwiper.currentImageIndex--;
                  doctorImagesSwiper.currentImageIndex +=
                      doctor.images.length;
                  doctorImagesSwiper.currentImageIndex %=
                      doctor.images.length;
                },
                child: PinchZoomImage(
                  image: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: SizedBox(
                      height: SizeConfig.screenHeight * 0.35,
                      width: SizeConfig.screenWidth * 0.75,
                      child: Image.network(
                        doctor.images[doctorImagesSwiper.currentImageIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    doctor.images.length,
                    (index) =>
                        buildSmallPreview(doctorImagesSwiper, index: index),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSmallPreview(DoctorImageSwiper doctorImagesSwiper,
      {@required int index}) {
    return GestureDetector(
      onTap: () {
        doctorImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        padding: EdgeInsets.all(getProportionateScreenHeight(8)),
        height: getProportionateScreenWidth(48),
        width: getProportionateScreenWidth(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: doctorImagesSwiper.currentImageIndex == index
                  ? kPrimaryColor
                  : Colors.transparent),
        ),
        child: Image.network(doctor.images[index]),
      ),
    );
  }
}
