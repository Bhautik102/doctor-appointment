import 'dart:io';

import 'package:block1/services/database/user_database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block1/components/default_button.dart';
import 'package:block1/exceptions/local_files_handling/image_picking_exceptions.dart';
import 'package:block1/exceptions/local_files_handling/local_file_handling_exception.dart';
import 'package:block1/models/report.dart';
import 'package:block1/services/database/report_database_helper.dart';
import 'package:block1/services/firestore_files_access/firestore_files_access_service.dart';
import 'package:block1/services/local_files_access/local_files_access_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import './edit_report_form.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import '../provider/report_detail.dart';
class EditReportForm extends StatefulWidget {
  final Report report;
  EditReportForm({
    Key key,
    this.report,
  }) : super(key: key);

  @override
  _EditReportFormState createState() => _EditReportFormState();
}

class _EditReportFormState extends State<EditReportForm> {
  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _tagStateKey = GlobalKey<TagsState>();

  final TextEditingController reportnameFieldController = TextEditingController();
 final    TextEditingController laboratoryNameFieldController = TextEditingController();

 
  // final TextEditingController sellerFieldController = TextEditingController();

  bool newReport = true;
  Report report;

  @override
  void dispose() {
    reportnameFieldController.dispose();
        laboratoryNameFieldController.dispose();

   

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.report== null) {
      report = Report(null);
      newReport = true;
    } else {
      report = widget.report;
      newReport = false;
      final reportDetails =
          Provider.of<ReportDetails>(context, listen: false);
      reportDetails.initialSelectedImages = widget.report.images
          .map((e) => CustomImage(imgType: ImageType.network, path: e))
          .toList();
      reportDetails.initialReportType = report.reportType;
      reportDetails.initSearchTags = report.searchTags ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        SizedBox(height: getProportionateScreenHeight(10)),
       
        buildUploadImagesTile(context),

        SizedBox(height: getProportionateScreenHeight(20)),

        buildReportTypeDropdown(),

        SizedBox(height: getProportionateScreenHeight(20)),
        buildReportSearchTagsTile(),

        SizedBox(height: getProportionateScreenHeight(80)),
        DefaultButton(
            text: "Save Report",
            press: () {
              saveReportButtonCallback(context);
            }),
        SizedBox(height: getProportionateScreenHeight(10)),
      ],
    );
    if (newReport == false) {
      reportnameFieldController.text = report.title;
      laboratoryNameFieldController.text=report.laboratoryName;
    
    }
    return column;
  }

  Widget buildReportSearchTags() {
    return Consumer<ReportDetails>(
      builder: (context, reportDetails, child) {
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
              reportDetails.addSearchTag(str.toLowerCase());
            },
          ),
          itemCount: reportDetails.searchTags.length,
          itemBuilder: (index) {
            final item = reportDetails.searchTags[index];
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
                  reportDetails.removeSearchTag(index: index);
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
          buildLaboratoryNameField(),
        
    
          SizedBox(height: getProportionateScreenHeight(20)),
         

        ],
      ),
    );
  }

  bool validateBasicDetailsForm() {
    if (_basicDetailsFormKey.currentState.validate()) {
      _basicDetailsFormKey.currentState.save();
      report.title = reportnameFieldController.text;
            report.laboratoryName = laboratoryNameFieldController.text;

    
      return true;
    }
    return false;
  }

  Widget buildReportTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: kTextColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Consumer<ReportDetails>(
        builder: (context, reportDetails, child) {
          return DropdownButton(
            value: reportDetails.reportType,
            items: ReportType.values
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
              "Chose Report Type",
            ),
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
            ),
            onChanged: (value) {
              reportDetails.reportType = value;
            },
            elevation: 0,
            underline: SizedBox(width: 0, height: 0),
          );
        },
      ),
    );
  }

  Widget buildReportSearchTagsTile() {
    return ExpansionTile(
      title: Text(
        "Search Tags",
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: Icon(Icons.check_circle_sharp),
      childrenPadding:
          EdgeInsets.symmetric(vertical: getProportionateScreenHeight(20)),
      children: [
        Text("Your report will be searched for this Tags"),
        SizedBox(height: getProportionateScreenHeight(15)),
        buildReportSearchTags(),
      ],
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      title: Text(
        "Upload Report Images",
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
        Consumer<ReportDetails>(
          builder: (context, reportDetails, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  reportDetails.selectedImages.length,
                  (index) => SizedBox(
                    width: 80,
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(index: index);
                        },
                        child: reportDetails.selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(
                                File(reportDetails.selectedImages[index].path)
                                    .readAsBytesSync())
                            : Image.network(
                                reportDetails.selectedImages[index].path),
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
      controller: reportnameFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        
        labelText: "Report Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (reportnameFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }




  Widget buildLaboratoryNameField() {
    return TextFormField(
      controller: laboratoryNameFieldController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText:
            "e.g., Enter HospitalName",
        labelText: "Laboratory Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (laboratoryNameFieldController.text.isEmpty) {
          return FIELD_REQUIRED_MSG;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: null,
    );
  }

  



 
  Future<void> saveReportButtonCallback(BuildContext context) async {
    if (validateBasicDetailsForm() == false) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Erros in Basic Details Form"),
        ),
      );
      return;
    }

    final reportDetails = Provider.of<ReportDetails>(context, listen: false);
    if (reportDetails.selectedImages.length < 1) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload atleast One Image of Report"),
        ),
      );
      return;
    }
    if (reportDetails.reportType == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select Report Type"),
        ),
      );
      return;
    }
    if (reportDetails.searchTags.length < 3) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Add atleast 3 search tags"),
        ),
      );
      return;
    }
    String reportId;
    String snackbarMessage;
    try {
      report.reportType = reportDetails.reportType;
      report.searchTags = reportDetails.searchTags;
      final reportUploadFuture = newReport
          ? UserDatabaseHelper().addUsersReport(report)
          : UserDatabaseHelper().updateUsersReport(report);
    reportUploadFuture.then((value) {
        reportId = value;
      });
      await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            reportUploadFuture,
            message:
                Text(newReport ? "Uploading Report" : "Updating Report"),
          );
        },
      );
      if (reportId != null) {
        snackbarMessage = "Report Info updated successfully";
      } else {
        throw "Couldn't update report info due to some unknown issue";
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
    if (reportId == null) return;
    bool allImagesUploaded = false;
    try {
      allImagesUploaded = await uploadReportImages(reportId);
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
    List<String> downloadUrls = reportDetails.selectedImages
        .map((e) => e.imgType == ImageType.network ? e.path : null)
        .toList();
    bool reportFinalizeUpdate = false;
    try {
      final updateReportFuture =
          UserDatabaseHelper().updateReportsImages(reportId, downloadUrls);
      reportFinalizeUpdate = await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            updateReportFuture,
            message: Text("Saving Report"),
          );
        },
      );
      if (reportFinalizeUpdate == true) {
        snackbarMessage = "Report uploaded successfully";
      } else {
        throw "Couldn't upload report properly, please retry";
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

  Future<bool> uploadReportImages(String reportId) async {
    bool allImagesUpdated = true;
    final reportDetails = Provider.of<ReportDetails>(context, listen: false);
    for (int i = 0; i < reportDetails.selectedImages.length; i++) {
      if (reportDetails.selectedImages[i].imgType == ImageType.local) {
        print("Image being uploaded: " + reportDetails.selectedImages[i].path);
        String downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(reportDetails.selectedImages[i].path),
              UserDatabaseHelper().getPathForReportImage(reportId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return FutureProgressDialog(
                imgUploadFuture,
                message: Text(
                    "Uploading Images ${i + 1}/${reportDetails.selectedImages.length}"),
              );
            },
          );
        } on FirebaseException catch (e) {
          Logger().w("Firebase Exception: $e");
        } catch (e) {
          Logger().w("Firebase Exception: $e");
        } finally {
          if (downloadUrl != null) {
            reportDetails.selectedImages[i] =
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
    final reportDetails = Provider.of<ReportDetails>(context, listen: false);
    if (index == null && reportDetails.selectedImages.length >= 3) {
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
      reportDetails.addNewSelectedImage(
          CustomImage(imgType: ImageType.local, path: path));
    } else {
      reportDetails.setSelectedImageAtIndex(
          CustomImage(imgType: ImageType.local, path: path), index);
    }
  }
}
