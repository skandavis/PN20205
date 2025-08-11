import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/DropDown.dart';
import 'package:flutter_application_2/formInput.dart';
import 'package:flutter_application_2/phoneNumberFormatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;
import 'package:flutter_application_2/globals.dart' as globals;

class contactUsPage extends StatefulWidget {
  const contactUsPage({super.key});

  @override
  State<contactUsPage> createState() => _contactUsPageState();
}

String selectedValue = 'Admin';
TextEditingController nameController = TextEditingController(text: globals.fields["name"]);
TextEditingController cityController = TextEditingController(text: globals.fields["city"]);
TextEditingController phoneController = TextEditingController(text: globals.fields["phone"]);
TextEditingController subjectController = TextEditingController();
TextEditingController messageController = TextEditingController();
FocusNode nameFocus = FocusNode();
FocusNode cityFocus = FocusNode();
FocusNode phoneFocus = FocusNode();
FocusNode subjectFocus = FocusNode();
FocusNode messageFocus = FocusNode();
FocusNode departmentFocus = FocusNode();

final SharedPreferencesAsync prefs = SharedPreferencesAsync();

class _contactUsPageState extends State<contactUsPage> {
  void sendMessage() async {
    utils.postRoute(
      {
        'name': nameController.text,
        'city': cityController.text,
        'phoneNumber': phoneController.text,
        "department": selectedValue,
        'subject': subjectController.text,
        'message': messageController.text,
      },
      'contact',
    );
  }

  void updateDepartment(String? value) {
    setState(() {
      selectedValue = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .05,
            ),
            formInput(
              focusNode: nameFocus,
              label: "Your Name",
              controller: nameController,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .025,
            ),
            formInput(
              focusNode: cityFocus,
              label: "City",
              controller: cityController,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .025,
            ),
            formInput(
              focusNode: phoneFocus,
              label: "Your Phone Number",
              controller: phoneController,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                PhoneNumberFormatter(),
              ]
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .025,
            ),
            formInput(
              focusNode: subjectFocus,
              label: "Subject",
              controller: subjectController,
            ),
            const SizedBox(
              height: 20,
            ),
            DropDown(
              focusNode: departmentFocus,
              options: ["Admin", "Events", "Food Committee", "Lost and Found"],
              label: "Choose the Department",
              initialValue: "Admin",
              onChanged: updateDepartment,
            ),
            const SizedBox(
              height: 20,
            ),
            formInput(
              label: "Your Message", 
              controller: messageController, 
              focusNode: messageFocus, 
              lines: 3,
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if (messageController.text.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    cityController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    subjectController.text.isNotEmpty) 
                {
                  sendMessage();
                } else {
                  utils.snackBarMessage(context, 'Not all fields are filled in!');
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * .8,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: globals.secondaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Send Message",
                      style: TextStyle(
                        color: globals.backgroundColor,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
