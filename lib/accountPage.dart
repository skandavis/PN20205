import 'package:flutter/services.dart';
import 'package:PN2025/accountProfile.dart';
import 'package:PN2025/phoneNumberFormatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/formInput.dart';
import 'package:PN2025/messageReciever.dart';
import 'package:app_set_id/app_set_id.dart';
import 'utils.dart' as utils;
import 'package:PN2025/globals.dart' as globals;

class accountPage extends StatefulWidget {
  const accountPage({super.key});

  @override
  State<accountPage> createState() => _accountPageState();
}
final SharedPreferencesAsync prefs = SharedPreferencesAsync();
String email = "";
String deviceID = "";
List<TextEditingController> controllers = [
  TextEditingController(text: globals.fields["name"]),
  TextEditingController(text: globals.fields["phone"]),
  TextEditingController(text: globals.fields["city"]),
  ];
List<FocusNode> inputFocusNodes = [FocusNode(),FocusNode(),FocusNode()];
Widget inputs = ListView.builder(itemCount: inputFocusNodes.length,itemBuilder: (context,index){
    return Column(
      children: [
        formInput(
          focusNode: inputFocusNodes[index],
          label: globals.fields.keys.toList()[index],
          formatters: index ==1?[
            FilteringTextInputFormatter.digitsOnly,
            PhoneNumberFormatter(),
          ]:null,
          lines: 1,
          controller: controllers[index],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * .025,
        ),
      ],
    );
  });
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
      "name": controllers[0].text,
      "phoneNumber":controllers[1].text,
      "city": controllers[2].text,

    }, 'device/$deviceID');
  }

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        backgroundColor: globals.backgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(
            "Account",
            style: TextStyle(
              color: Colors.white,
              fontSize:Theme.of(context).textTheme.displaySmall?.fontSize,
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
                child: inputs,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .025,
              ),
              
              GestureDetector(
                onTap: () {
                  prefs.setString('name', controllers[0].text);
                  prefs.setString('phone', controllers[1].text);
                  prefs.setString('city', controllers[2].text);
                  globals.fields.update('name', (value) => controllers[0].text);
                  globals.fields.update('phone', (value) => controllers[1].text);
                  globals.fields.update('city', (value) => controllers[2].text);
                  sendData();
                  utils.snackBarMessage(context, "Account Details Updated!",color: Colors.green);
                  Navigator.of(context).pop();
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
