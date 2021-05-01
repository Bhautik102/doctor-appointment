import 'package:block1/components/nothingtoshow_container.dart';
import 'package:block1/components/doctor_card.dart';
import 'package:block1/components/rounded_icon_button.dart';
import 'package:block1/components/search_field.dart';
import 'package:block1/constants.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/doctor_details/doctor_details_screen.dart';
import 'package:block1/screens/search_result/search_result_screen.dart';
import 'package:block1/services/data_streams/category_doctors_stream.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/size_config.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class Body extends StatefulWidget {
  final DoctorType doctorType;

  Body({
    Key key,
    @required this.doctorType,
  }) : super(key: key);

  @override
  _BodyState createState() =>
      _BodyState(categoryDoctorsStream: CategoryDoctorsStream(doctorType));
}

class _BodyState extends State<Body> {
  final CategoryDoctorsStream categoryDoctorsStream;

  _BodyState({@required this.categoryDoctorsStream});

  @override
  void initState() {
    super.initState();
    categoryDoctorsStream.init();
  }

  @override
  void dispose() {
    super.dispose();
    categoryDoctorsStream.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: getProportionateScreenHeight(20)),
                  buildHeadBar(),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.13,
                    child: buildCategoryBanner(),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.68,
                    child: StreamBuilder<List<String>>(
                      stream: categoryDoctorsStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<String> doctorsId = snapshot.data;
                          if (doctorsId.length == 0) {
                            return Center(
                              child: NothingToShowContainer(
                                secondaryMessage:
                                    "No Doctors in ${EnumToString.convertToString(widget.doctorType)}",
                              ),
                            );
                          }

                          return buildDoctorsGrid(doctorsId);
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeadBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedIconButton(
          iconData: Icons.arrow_back_ios,
          press: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(width: 5),
        Expanded(
          child: SearchField(
            onSubmit: (value) async {
              final query = value.toString();
              if (query.length <= 0) return;
              List<String> searchedDoctorsId;
              try {
                searchedDoctorsId = await DoctorDatabaseHelper()
                    .searchInDoctors(query.toLowerCase(),
                        doctorType: widget.doctorType);
                if (searchedDoctorsId != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultScreen(
                        searchQuery: query,
                        searchResultDoctorsId: searchedDoctorsId,
                        searchIn:
                            EnumToString.convertToString(widget.doctorType),
                      ),
                    ),
                  );
                  await refreshPage();
                } else {
                  throw "Couldn't perform search due to some unknown reason";
                }
              } catch (e) {
                final error = e.toString();
                Logger().e(error);
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$error"),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> refreshPage() {
    categoryDoctorsStream.reload();
    return Future<void>.value();
  }

  Widget buildCategoryBanner() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bannerFromDoctorType()),
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                kPrimaryColor,
                BlendMode.hue,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              EnumToString.convertToString(widget.doctorType),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDoctorsGrid(List<String> doctorsId) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: doctorsId.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return DoctorCard(
            doctorId: doctorsId[index],
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailsScreen(
                    doctorId: doctorsId[index],
                  ),
                ),
              ).then(
                (_) async {
                  await refreshPage();
                },
              );
            },
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 2,
          mainAxisSpacing: 8,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
      ),
    );
  }

  String bannerFromDoctorType() {
    switch (widget.doctorType) {
      case DoctorType.General:
        return "assets/images/General.jpg";
      case DoctorType.Dentist:
        return "assets/images/Dentist.jpg";
      case DoctorType.Psychiatric:
        return "assets/images/Psychiatric.jpg";
      case DoctorType.Children:
        return "assets/images/Children.jpg";
      case DoctorType.HeartSurgen:
        return "assets/images/Heart.jpg";
      case DoctorType.Others:
        return "assets/images/Other.jpg";
      default:
        return "assets/images/Other.jpg";
    }
  }
}
