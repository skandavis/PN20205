import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/imageLoader.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/participant.dart';
import 'package:NagaratharEvents/participantDetailTile.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/material.dart';

class ParticipantDetailDialog extends StatefulWidget {
  final Participant participant;
  final Function(String?) onImageUpdated;
  final Function(Map<String,dynamic>) onDataChanged;

  const ParticipantDetailDialog({
    super.key,
    required this.participant,
    required this.onImageUpdated,
    required this.onDataChanged,
  });

  @override
  State<ParticipantDetailDialog> createState() => _ParticipantDetailDialogState();
}

class _ParticipantDetailDialogState extends State<ParticipantDetailDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController emailController;
  late String selectedGender;
  late String selectedCity;
  late int selectedAge;
  late Map<String, dynamic> oldData;

  bool isEditing = false;
  bool isLoading = false;

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> cityOptions = ['Austin', 'Houston', 'Dallas'];
  
  @override
  void initState() {
    super.initState();
    final participant = widget.participant;
    nameController = TextEditingController(text: participant.name);
    descriptionController = TextEditingController(text: participant.description);
    emailController = TextEditingController(text: participant.email);
    selectedGender = participant.gender;
    selectedCity = participant.city;
    selectedAge = participant.age;
    oldData = {
      'name': nameController.text,
      'about': descriptionController.text,
      'emailId': emailController.text,
      'gender': selectedGender,
      'city': selectedCity,
      'age': selectedAge
    };
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveChanges(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, dynamic> data = {
      'name': nameController.text,
      'about': descriptionController.text,
      'emailId': emailController.text,
      'gender': selectedGender,
      'city': selectedCity,
      'age': selectedAge
    };

    Map<String, dynamic> updatedData = Map.from(data);
    data.forEach((key, value) {
      if (value == null || (value is String && value.trim().isEmpty) || (value == oldData[key])) {
        updatedData.remove(key);
      }
    });

    if(updatedData.isEmpty){
      utils.snackBarAboveMessage('No changes made');
      return;
    }

    if (updatedData.keys.contains('emailId') &&
        !utils.isValidEmail(updatedData['emailId'])) {
      utils.snackBarAboveMessage('Please enter a valid email');
      return;
    }

    setState(() {
      isLoading = true;
    });
    final response = await NetworkService().patchRoute(
      updatedData, 
      'participants/${widget.participant.id}', 
      showAboveSnackBar: true
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (response.statusCode != 200) return;

    utils.snackBarAboveMessage('Details updated successfully', color: Colors.green);

    updateParticipant();
    resetFields();

    widget.onDataChanged(updatedData);
  }

  void updateParticipant(){
    setState(() {
      widget.participant.name =
          nameController.text.isEmpty ? widget.participant.name : nameController.text;
      widget.participant.description =
          descriptionController.text.isEmpty ? widget.participant.description : descriptionController.text;
      widget.participant.email =
          emailController.text.isEmpty ? widget.participant.email : emailController.text;
      widget.participant.gender = selectedGender;
      widget.participant.city = selectedCity;
      widget.participant.age = selectedAge;
      isEditing = false;
    });
  }

  void resetFields() {
    final participant = widget.participant;
    setState(() {
      nameController.text = participant.name;
      descriptionController.text = participant.description;
      emailController.text = participant.email;
      selectedGender = participant.gender;
      selectedCity = participant.city;
      selectedAge = participant.age;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    return Dialog(
      constraints: BoxConstraints(maxHeight: 500),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isEditing && widget.participant.isEditable)
                        IconButton(
                          onPressed: (){
                            setState(() {
                              isEditing = true;
                            });
                          },
                          icon: Icon(Icons.edit, color: globals.accentColor, size: 32),
                          tooltip: "Edit Profile",
                        )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16,),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          imageLoader(
                            fileName: "${participant.name}Profile.jpg",
                            buttonSize: 35,
                            circle: true,
                            size: 150,
                            showAboveSnackBar: true,
                            imageRoute: participant.image,
                            uploadRoute: isEditing ? "participants/${participant.id}/photo" : null,
                            deleteRoute: isEditing ? "participants/${participant.id}/photo" : null,
                            onDelete: isEditing ? () {
                              participant.image = null;
                              widget.onImageUpdated(null);
                            } : null,
                            onUpload: isEditing ? (file) {
                              participant.image = file.path;
                              widget.onImageUpdated(file.path);
                            } : null,
                          ),
                          SizedBox(height: 16),
                          isEditing ? gradientTextField(
                            icon: Icons.email,
                            label: "Email",
                            hint: "Email",
                            controller: emailController,
                          ): 
                          Text(
                            participant.email,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: globals.bodyFontSize,
                            ),
                          ),
                          SizedBox(height: 8),
                          isEditing
                            ? gradientTextField(
                                icon: Icons.abc,
                                label: "Name",
                                hint: "John",
                                controller: nameController,
                              )
                            : Text(
                                participant.name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: globals.subTitleFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          SizedBox(height: 8),
                          isEditing
                            ? gradientTextField(
                                icon: Icons.description,
                                label: "Description",
                                hint: "Description here",
                                controller: descriptionController,
                                maxLines: 3,
                              )
                            : Text(
                                participant.description,
                                style: TextStyle(
                                  fontSize: globals.paraFontSize,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          SizedBox(height: 20),
                          if (isEditing)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      "Gender",
                                      selectedGender,
                                      genderOptions,
                                      Icons.wc,
                                      (value) => setState(() => selectedGender = value!),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAgeDropdown(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              _buildDropdownField(
                                "Location",
                                selectedCity,
                                cityOptions,
                                Icons.location_on,
                                (value) => setState(() => selectedCity = value!),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                    color: Color.fromARGB(255, 31, 53, 76),
                  ),
                  child: isEditing ? Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: resetFields,
                            icon: Icon(Icons.close, size: 18),
                            label: Text(
                              "Cancel",
                              style: TextStyle(fontSize: globals.bodyFontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (){
                              saveChanges(context);
                            },
                            icon: Icon(Icons.check, size: 18),
                            label: Text(
                              "Save",
                              style: TextStyle(fontSize: globals.bodyFontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: globals.secondaryColor,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Row(
                    children: [
                      participantDetailTile(
                        icon: Icons.wc,
                        title: "Gender",
                        value: participant.gender,
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: const Color.fromARGB(100, 0, 0, 0),
                        width: 1,
                      ),
                      participantDetailTile(
                        icon: Icons.location_on,
                        title: "Location",
                        value: participant.city,
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: const Color.fromARGB(100, 0, 0, 0),
                        width: 1,
                      ),
                      participantDetailTile(
                        icon: Icons.cake,
                        title: "Age",
                        value: participant.age.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    IconData icon,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: globals.secondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: globals.secondaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAgeDropdown() {
    final ageOptions = List<int>.generate(97, (index) => index + 3);
    return DropdownButtonFormField<int>(
      initialValue: selectedAge,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: "Age",
        prefixIcon: Icon(Icons.cake, color: globals.secondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: globals.secondaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: ageOptions.map((int age) {
        return DropdownMenuItem<int>(
          value: age,
          child: Text(age.toString()),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedAge = value!),
    );
  }
}