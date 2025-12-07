import 'dart:io';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/imageLoader.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/participant.dart';
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
  late String selectedGender;
  late String selectedCity;
  late int selectedAge;
  bool isEditing = false;

  final List<String> genderOptions = ['Boy', 'Girl'];
  final List<String> cityOptions = ['Austin', 'Houston', 'Dallas'];

  @override
  void initState() {
    super.initState();
    final participant = widget.participant;
    nameController = TextEditingController(text: participant.name);
    descriptionController = TextEditingController(text: participant.description);
    selectedGender = participant.gender;
    selectedCity = participant.city;
    selectedAge = participant.age;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveChanges() async{
    Map<String, dynamic> data = {
      'name': nameController.text,
      'about': descriptionController.text,
      'gender': selectedGender,
      'city': selectedCity,
      'age': selectedAge
    };
    final response = await NetworkService().patchRoute(data, 'participants/${widget.participant.id}');
    if(response.statusCode != 200) return;
    setState(() {
      widget.participant.name = nameController.text;
      widget.participant.description = descriptionController.text;
      widget.participant.gender = selectedGender;
      widget.participant.city = selectedCity;
      widget.participant.age = selectedAge;
      isEditing = false;
    });
    widget.onDataChanged(data);
  }

  void cancelEditing() {
    final participant = widget.participant;
    setState(() {
      nameController.text = participant.name;
      descriptionController.text = participant.description;
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: Colors.white,
        ),
        constraints: BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isEditing)
                      IconButton(
                        color: Colors.green,
                        onPressed: () => setState(() => isEditing = true),
                        icon: Icon(Icons.edit, color: globals.accentColor,size: 32,),
                        tooltip: "Edit Profile",
                      )
                    else
                      SizedBox(width: 48),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Center(
                      child: imageLoader(
                        buttonSize: 35,
                        circle: true,
                        size: 150,
                        imageRoute: participant.image,
                        uploadRoute: !isEditing ? "participants/${participant.id}/photo" : null,
                        deleteRoute: isEditing ? "participants/${participant.id}/photo" : null,
                        onDelete: isEditing ? () {
                          participant.image = null;
                          widget.onImageUpdated(null);
                        } : null,
                        onUpload:  !isEditing ? (file){
                          participant.image = file.path;
                          widget.onImageUpdated(file.path);
                        } : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Name field
                    isEditing
                        ? gradientTextField(icon: Icons.abc, label: "Name", hint: "John", controller: nameController)
                        : Text(
                            participant.name,
                            style: TextStyle(color: Colors.black, fontSize: 28),
                            textAlign: TextAlign.center,
                          ),
                    SizedBox(height: 8),
                    // Description field
                    isEditing
                        ? gradientTextField(icon: Icons.description, label: "Description", hint: "Description here", controller: descriptionController, maxLines: 3)
                        : Text(
                            participant.description,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                    SizedBox(height: 20),
                    // Detail fields
                    if (isEditing) ...[
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
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                  color: Color.fromARGB(255, 31, 53, 76),
                ),
                child: isEditing
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: cancelEditing,
                                icon: Icon(Icons.close, size: 18),
                                label: Text("Cancel", style: TextStyle(fontSize: 13)),
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
                                onPressed: saveChanges,
                                icon: Icon(Icons.check, size: 18),
                                label: Text("Save", style: TextStyle(fontSize: 13)),
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
                          _buildInfoTile(
                            Icons.wc,
                            "Gender",
                            participant.gender,
                          ),
                          VerticalDivider(
                            thickness: 2,
                            color: const Color.fromARGB(100, 0, 0, 0),
                            width: 0,
                          ),
                          _buildInfoTile(
                            Icons.location_on,
                            "Location",
                            participant.city,
                          ),
                          VerticalDivider(
                            thickness: 2,
                            color: const Color.fromARGB(100, 0, 0, 0),
                            width: 0,
                          ),
                          _buildInfoTile(
                            Icons.cake,
                            "Age",
                            participant.age.toString(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
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

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: globals.secondaryColor, size: 28),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: globals.secondaryColor, fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}