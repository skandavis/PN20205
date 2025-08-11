import 'package:flutter_application_2/accountProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/formInput.dart';
import 'package:flutter_application_2/messageReciever.dart';
import 'package:app_set_id/app_set_id.dart';
import 'utils.dart' as utils;
import 'package:flutter_application_2/globals.dart' as globals;

class accountPage extends StatefulWidget {
  const accountPage({super.key});

  @override
  State<accountPage> createState() => _accountPageState();
}

TextEditingController cityController = TextEditingController(text: globals.fields["city"]);
TextEditingController nameController = TextEditingController(text: globals.fields["name"]);
TextEditingController phoneController = TextEditingController(text: globals.fields["name"]);
final SharedPreferencesAsync prefs = SharedPreferencesAsync();
String email = "";
String deviceID = "";
List<FocusNode> inputFocusNodes = [FocusNode(),FocusNode(),FocusNode()];

class _accountPageState extends State<accountPage> {
  void getDeviceId() async {
    deviceID = (await AppSetId().getIdentifier())!;
  }

  @override
  void initState() {
    super.initState();
    debugPrint(globals.fields.toString());
    getDeviceId();
  }

  void sendData() async {
    utils.patchRoute({
      "email": "viswanathanmanickam5@gmail.com",
      "city": cityController.text,
      "name": nameController.text,
      "phoneNumber": phoneController.text,
    }, 'device/$deviceID');
  }

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        backgroundColor: globals.backgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            "Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          backgroundColor: globals.backgroundColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // make circle
              accountProfile(),
              const SizedBox(
                height: 20,
              ),
              Text(
                globals.fields["email"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height*.3,
                child: ListView.builder(itemCount: inputFocusNodes.length,itemBuilder: (context,index){
                  return Column(
                    children: [
                      formInput(
                        focusNode: inputFocusNodes[index],
                        label: globals.fields.keys.toList()[index],
                        controller: TextEditingController(text:globals.fields.values.toList()[index]),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .025,
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .025,
              ),
              
              GestureDetector(
                onTap: () {
                  prefs.setString('city', cityController.text);
                  prefs.setString('phone', phoneController.text);
                  prefs.setString('name', nameController.text);
                  sendData();
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
                        "Save",
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
      ),
    );
  }
}
