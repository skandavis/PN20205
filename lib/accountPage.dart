import 'package:PN2025/networkService.dart';
import 'package:PN2025/user.dart';
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
List<String> labels = ["Name","Phone","City"];
User user = User.instance;
List<TextEditingController> controllers = [
  TextEditingController(text: user.name),
  TextEditingController(text: user.phone),
  TextEditingController(text: user.city),
  ];
List<FocusNode> inputFocusNodes = [FocusNode(),FocusNode(),FocusNode()];
Widget inputs = ListView.builder(itemCount: inputFocusNodes.length,itemBuilder: (context,index){
    return Column(
      children: [
        formInput(
          focusNode: inputFocusNodes[index],
          label:labels[index],
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
    getDeviceId();
  }

  void sendData() async {
    await NetworkService().patchRoute({
      // "email": "viswanathanmanickam5@gmail.com",
      "name": controllers[0].text,
      "phoneNumber":controllers[1].text,
      "city": controllers[2].text,

    }, 'users');
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
                user.email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(
                height: 20,
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
                  user.setPersonalInfo({
                    'name':controllers[0].text,
                    'phone':controllers[1].text,
                    'city':controllers[2].text
                  });
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
