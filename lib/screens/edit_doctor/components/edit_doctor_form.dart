import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block1/components/default_button.dart';
import 'package:block1/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:block1/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:block1/models/Doctor.dart';
import 'package:block1/screens/edit_doctor/provider_models/DoctorDetails.dart';
import 'package:block1/services/database/doctor_database_helper.dart';
import 'package:block1/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:block1/services/local_files_access/local_files_access_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class EditDoctorForm extends StatefulWidget {
  final Doctor doctor;
  EditDoctorForm({
    Key key,
    this.doctor,
  }) : super(key: key);

  @override
  _EditDoctorFormState createState() => _EditDoctorFormState();
}

class _EditDoctorFormState extends State<EditDoctorForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeDoctorFormKey = GlobalKey<FormState>();
  final _tagStateKey = GlobalKey<TagsState>();

  final TextEditingController doctornameFieldController = TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
 final    TextEditingController hospitalNameFieldController = TextEditingController();

  // final TextEditingController discountPriceFieldController =
  //     TextEditingController();
  // final TextEditingController originalPriceFieldController =
  //     TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();

  bool newDoctor = true;
  Doctor doctor;

  @override
  void dispose() {
    doctornameFieldController.dispose();
    variantFieldController.dispose();
        hospitalNameFieldController.dispose();

    // discountPriceFieldController.dispose();
    // originalPriceFieldController.dispose();
    highlightsFieldController.dispose();
    desciptionFieldController.dispose();
    sellerFieldController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.doctor == null) {
      doctor = Doctor(null);
      newDoctor = true;
    } else {
      doctor = widget.doctor;
      newDoctor = false;
      final doctorDetails =
          Provider.of<DoctorDetails>(context, listen: false);
      doctorDetails.initialSelectedImages = widget.doctor.images
          .map((e) => CustomImage(imgType: ImageType.network, path: e))
          .toList();
      doctorDetails.initialDoctorType = doctor.doctorType;
      doctorDetails.initSearchTags = doctor.searchTags ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildDescribeDoctorTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
        buildUploadImagesTile(context),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildDoctorTypeDropdown(),
        SizedBox(height: getProportionateScreenHeight(20)),
        buildDoctorSearchTagsTile(),
        SizedBox(height: getProportionateScreenHeight(80)),
        DefaultButton(
            text: "Save Doctor",
            press: () {
              saveDoctorButtonCallback(context);
            }),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
    if (newDoctor == false) {
      doctornameFieldController.text = doctor.title;
      hospitalNameFieldController.text=doctor.hospitalName;
      variantFieldController.text = doctor.qualification;
      // discountPriceFieldController.text = doctor.discountPrice.toString();
      // originalPriceFieldController.text = doctor.originalPrice.toString();
      highlightsFieldController.text = doctor.highlights;
      desciptionFieldController.text = doctor.description;
      sellerFieldController.text = doctor.seller;
    }
    return column;
  }

  Widget buildDoctorSearchTags() {
    return Consumer<DoctorDetails>(
      builder: (context, doctorDetails, child) {
        return Tags(
          key: _tagStateKey,
          horizontalScroll: true,
          heightHorizontalScroll: getProportionateScreenHeight(80),
          textField: TagsTextField(
            lowerCase: true,
            width: getProportionateScreenWidth(120),
            constraintSuggestion: true,
            hintText: "Add search tag",
            keyboardType: TextInputType.name,
            onSubmitted: (String str) {
              doctorDetails.addSearchTag(str.toLowerCase());
            },
          ),
          itemCount: doctorDetails.searchTags.length,
          itemBuilder: (index) {
            final item = doctorDetails.searchTags[index];
            return ItemTags(
              index: index,
              title: item,
              active: true,
              activeColor: kPrimaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              alignment: MainAxisAlignment.spaceBetween,
              removeButton: ItemTagsRemoveButton(
                backgroundColor: Colors.white,
                color: kTextColor,
                onRemoved: () {
                  doctorDetails.removeSearchTag(index: index);
                  return true;
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Basic Details",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.local_hospital_sharp,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildTitleField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildHospitalNameField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildVariantField(),
          // SizedBox(height: getProportionateScreenHeight(20)),
          // buildOriginalPriceField(),
          // SizedBox(height: getProportionateScreenHeight(20)),
          // buildDiscountPriceField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildSellerField(),
          SizedBox(height: getProportionateScreenHeight(20)),
     

        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState.validate()) {
      _basicDetailsFormKey.currentState.save();
      doctor.title = doctornameFieldController.text;
            doctor.hospitalName = hospitalNameFieldController.text;

      doctor.qualification = variantFieldController.text;
      // doctor.originalPrice = double.parse(originalPriceFieldController.text);
      // doctor.discountPrice = double.parse(discountPriceFieldController.text);
      doctor.seller = sellerFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildDescribeDoctorTile(BuildContext context) {
    return Form(
      key: _describeDoctorFormKey,
      child: ExpansionTile(
        maintainState: true,
        title: Text(
          "Describe Doctor",
          style: Theme.of(context).textTheme.headline6,
        ),
        leading: Icon(
          Icons.description,
        ),
        childrenPadding:
            EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
        children: [
          buildHighlightsField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildDescriptionField(),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  bool validateDescribeDoctorForm() {
    if (_describeDoctorFormKey.currentState.validate()) {
      _describeDoctorFormKey.currentState.save();
      doctor.highlights = highlightsFieldController.text;
      doctor.description = desciptionFieldController.text;
      return true;
    }
    return false;
  }

  Widget buildDoctorTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<DoctorDetails>(
        builder: (context, doctorDetails, child) {
          return DropdownButton(
            value: doctorDetails.doctorType,
            items: DoctorType.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      EnumToString.convertToString(e),
                    ),
                  ),
                )
                .toList(),
            hint: Text(
              "Chose Doctor Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              doctorDetails.doctorType = value;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildDoctorSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.check_circle_sharp),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Text("Your doctor will be searched for this Tags"),
        SizedBox(height: getProportionateScreenHeight(15)),
        buildDoctorSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Doctor Images",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.image),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              icon: Icon(
                Icons.add_a_photo,
              ),
              color: kTextColor,
              onPressed: () {
                addImageButtonCallback();
              }),
        ),
        Consumer<DoctorDetails>(
          builder: (context, doctorDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  doctorDetails.selectedImages.length,
                  (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: doctorDetails.selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(
                                File(doctorDetails.selectedImages[index].path)
                                    .readAsBytesSync())
                            : Image.network(
                                doctorDetails.selectedImages[index].path),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      controller: doctornameFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "Ghanshyam Patel",
        labelText: "Doctor Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (doctornameFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      controller: variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: "e.g., MD, MBBS",
        labelText: "Doctor Qualification",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (variantFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildHighlightsField() {
    return TextFormField(
      controller: highlightsFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., Treatment Provided by Doctor",
        labelText: "Highlights",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (highlightsFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildHospitalNameField() {
    return TextFormField(
      controller: hospitalNameFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., Enter HospitalName",
        labelText: "Hospital Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (hospitalNameFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: desciptionFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g.,Other Information About Doctor",
        labelText: "Description",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (desciptionFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  Widget buildSellerField() {
    return TextFormField(
      controller: sellerFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
         hintText: "e.g., 7 Years ",
        labelText: "Experiance",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (sellerFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  // Widget buildOriginalPriceField() {
  //   return TextFormField(
  //     controller: originalPriceFieldController,
  //     keyboardType: TextInputType.number,
  //     decoration: InputDecoration(
  //       hintText: "e.g., 5999.0",
  //       labelText: "Original Price (in INR)",
  //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //     ),
  //     validator: (_) {
  //       if (originalPriceFieldController.text.isEmpty) {
  //         return FIELD_REQUIRED_MSG;
  //       }
  //       return null;
  //     },
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //   );
  // }

  // Widget buildDiscountPriceField() {
  //   return TextFormField(
  //     controller: discountPriceFieldController,
  //     keyboardType: TextInputType.number,
  //     decoration: InputDecoration(
  //       hintText: "e.g., 2499.0",
  //       labelText: "Discount Price (in INR)",
  //       floatingLabelBehavior: FloatingLabelBehavior.always,
  //     ),
  //     validator: (_) {
  //       if (discountPriceFieldController.text.isEmpty) {
  //         return FIELD_REQUIRED_MSG;
  //       }
  //       return null;
  //     },
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //   );
  // }

  Future<void> saveDoctorButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Erros in Basic Details Form"),
        ),
      );
      return;
    }
    if (validateDescribeDoctorForm() == false) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Errors in Describe Doctor Form"),
        ),
      );
      return;
    }
    final doctorDetails = Provider.of<DoctorDetails>(context, listen: false);
    if (doctorDetails.selectedImages.length < 1) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload atleast One Image of Doctor"),
        ),
      );
      return;
    }
    if (doctorDetails.doctorType == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Doctor Type"),
        ),
      );
      return;
    }
    if (doctorDetails.searchTags.length < 3) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Add atleast 3 search tags"),
        ),
      );
      return;
    }
    String doctorId;
    String snackbarMessage;
    try {
      doctor.doctorType = doctorDetails.doctorType;
      doctor.searchTags = doctorDetails.searchTags;
      final doctorUploadFuture = newDoctor
          ? DoctorDatabaseHelper().addUsersDoctor(doctor)
          : DoctorDatabaseHelper().updateUsersDoctor(doctor);
    doctorUploadFuture.then((value) {
        doctorId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            doctorUploadFuture,
            message:
                Text(newDoctor ? "Uploading Doctor" : "Updating Doctor"),
          );
        },
      );
      if (doctorId != null) {
        snackbarMessage = "Doctor Info updated successfully";
      } else {
        throw "Couldn't update doctor info due to some unknown issue";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    if (doctorId == null) return;
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadDoctorImages(doctorId);
      if (allImagesUploaded == true) {
        snackbarMessage = "All images uploaded successfully";
      } else {
        throw "Some images couldn't be uploaded, please try again";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = "Something went wrong";
    } finally {
      Logger().i(snackbarMessage);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    List<String> downloadUrls = doctorDetails.selectedImages
        .map((e) => e.imgType == ImageType.network ? e.path : null)
        .toList();
    bool doctorFinalizeUpdate = false;
    try {
      final updateDoctorFuture =
          DoctorDatabaseHelper().updateDoctorsImages(doctorId, downloadUrls);
      doctorFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateDoctorFuture,
            message: Text("Saving Doctor"),
          );
        },
      );
      if (doctorFinalizeUpdate == true) {
        snackbarMessage = "Doctor uploaded successfully";
      } else {
        throw "Couldn't upload doctor properly, please retry";
      }
    } on FirebaseException catch (e) {
      Logger().w("Firebase Exception: $e");
      snackbarMessage = "Something went wrong";
    } catch (e) {
      Logger().w("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      Logger().i(snackbarMessage);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMessage),
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<bool> uploadDoctorImages(String doctorId) async {
    bool allImagesUpdated = true;
    final doctorDetails = Provider.of<DoctorDetails>(context, listen: false);
    for (int i = 0; i < doctorDetails.selectedImages.length; i++) {
      if (doctorDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + doctorDetails.selectedImages[i].path);
        String downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(doctorDetails.selectedImages[i].path),
              DoctorDatabaseHelper().getPathForDoctorImage(doctorId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text(
                    "Uploading Images ${i + 1}/${doctorDetails.selectedImages.length}"),
              );
            },
          );
        } on FirebaseException catch (e) {
          Logger().w("Firebase Exception: $e");
        } catch (e) {
          Logger().w("Firebase Exception: $e");
        } finally {
          if (downloadUrl != null) {
            doctorDetails.selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Couldn't upload image ${i + 1} due to some issue"),
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  Future<void> addImageButtonCallback({int index}) async {
    final doctorDetails = Provider.of<DoctorDetails>(context, listen: false);
    if (index == null && doctorDetails.selectedImages.length >= 3) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Max 3 images can be uploaded")));
      return;
    }
    String path;
    String snackbarMessage;
    try {
      path = await choseImageFromLocalFiles(context);
      if (path == null) {
        throw LocalImagePickingUnknownReasonFailureException();
      }
    } on LocalFileHandlingException catch (e) {
      Logger().i("Local File Handling Exception: $e");
      snackbarMessage = e.toString();
    } catch (e) {
      Logger().i("Unknown Exception: $e");
      snackbarMessage = e.toString();
    } finally {
      if (snackbarMessage != null) {
        Logger().i(snackbarMessage);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMessage),
          ),
        );
      }
    }
    if (path == null) {
      return;
    }
    if (index == null) {
      doctorDetails.addNewSelectedImage(
          CustomImage(imgType: ImageType.local, path: path));
    } else {
      doctorDetails.setSelectedImageAtIndex(
          CustomImage(imgType: ImageType.local, path: path), index);
    }
  }
}
