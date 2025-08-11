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


final SharedPreferencesAsync prefs = SharedPreferencesAsync();

class _contactUsPageState extends State<contactUsPage> {
  List<String> values = ["Admin", "Events", "Food Committee", "Lost and Found"];
  late String selectedValue = values[0];
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
  bool loading = false;
  Future<bool> sendMessage() async => utils.postRoute(
      {
        'name': nameController.text,
        'city': cityController.text,
        'phoneNumber': phoneController.text,
        "department": selectedValue,
        'subject': subjectController.text,
        'message': messageController.text,
      },
      'contact',
    ).then((statusCode){
      return statusCode == 200;
    });

  void updateDepartment(String? value) {
    setState(() {
      selectedValue = value!;
    });
  }
  Future<void> submitForm()
  async {
    FocusScope.of(context).unfocus();
    if (messageController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        subjectController.text.isNotEmpty) 
    {
      setState(() {
        loading = true;                      
      });
      bool success = await sendMessage();
      if(success)
      {
        setState(() {
          loading = false;                          
        });
        subjectController.clear();
        messageController.clear();
        utils.snackBarMessage(context, 'Message Sent!',color: Colors.green);
      }
      else{
        setState(() {
          loading = false;                          
        });
        utils.snackBarMessage(context, "Unable to send Message!");
      }
    } else {
      utils.snackBarMessage(context, 'Not all fields are filled in!');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .05,
                ),
                formInput(
                  focusNode: nameFocus,
                  lines: 1,
                  label: "Your Name",
                  controller: nameController,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .025,
                ),
                formInput(
                  focusNode: cityFocus,
                  lines: 1,
                  label: "City",
                  controller: cityController,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .025,
                ),
                formInput(
                  focusNode: phoneFocus,
                  lines: 1,
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
                  lines: 1,
                  label: "Subject",
                  controller: subjectController,
                ),
                const SizedBox(
                  height: 20,
                ),
                DropDown(
                  focusNode: departmentFocus,
                  options: values,
                  label: "Choose the Department",
                  initialValue: selectedValue,
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
                  onTap: submitForm,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    height: 100,
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
          if(loading)
          Container(
            color: Color.fromARGB(120, 0, 0, 0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: globals.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
