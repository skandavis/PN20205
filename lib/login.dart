import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding
import 'dart:io' show Platform;
import 'package:app_set_id/app_set_id.dart';
import 'package:flutter_application_2/globals.dart' as globals;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_2/homePage.dart';
import 'package:flutter_application_2/messageReciever.dart' show messageReciever;
import 'package:flutter_application_2/sendPasswordPage.dart';
import 'package:flutter_application_2/submit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart' as utils;
class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

String deviceId = "";
String ApnsToken = "";
TextEditingController pin = TextEditingController();
TextEditingController email = TextEditingController();
final FocusNode emailFocus = FocusNode();
final FocusNode pinFocus = FocusNode();

Future<bool> authenticate(String email, String pin) async {
  debugPrint("deviceId: $deviceId");
  debugPrint("ApnsID: $ApnsToken");
  var url = Uri.parse('${globals.url}authenticate');
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "passcode": pin,
      "deviceID": deviceId,
      "evntID": 1,
      "deviceAPN": ApnsToken,
    }),
  );
  if (response.statusCode == 200) {
    debugPrint("Success");
    globals.token = response.headers["set-cookie"].toString().split(";")[0];
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    prefs.setString('email', email);
    prefs.setString('userType', json.decode(response.body)["type"]??'User');
    await prefs.setString('cookie', globals.token);
    return true;
  }
  debugPrint("Fail");
  return false;
}

class _loginPageState extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    getToken();
    getDeviceId();
    return messageReciever(
      body: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromARGB(255, 24, 19, 118),
              Colors.black,
            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.1),
                      child: Text(
                        "Hello \nSign in!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Theme.of(context).textTheme.displayMedium?.fontSize,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(MediaQuery.sizeOf(context).width*.1),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          TextField(
                            focusNode: emailFocus,
                            decoration:
                                const InputDecoration(labelText: "Email"),
                            controller: email,
                            onSubmitted: (email) {
                              if(pin.text.isEmpty)
                              {
                                FocusScope.of(context).requestFocus(pinFocus);
                                return;
                              }
                              login(email, pin.text, context);
                            },
                          ),
                          const SizedBox(height: 50),
                          TextField(
                            focusNode: pinFocus,
                            decoration: const InputDecoration(labelText: "PIN"),
                            controller: pin,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onSubmitted: (pin){
                              login(email.text, pin,context);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          sendPasswordPage(title: "Reset\nPassword",buttonLabel: "Reset",),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      submitButton(
                        text: "Login", 
                        onSubmit: (){
                        login(email.text, pin.text,context);
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          sendPasswordPage(title: "Create\nAccount",buttonLabel: "Register",),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void login (String email,String pin, BuildContext context) 
  {
    if(email.isEmpty&& pin.isEmpty){
      email = "viswanathanmanickam5@gmail.com";
      pin = "6602";
    }
    if (email.isEmpty || pin.isEmpty) {
      utils.snackBarMessage(context, 'Please enter email or password');
      return;
    }
    if(pin.length!=4)
    {
      utils.snackBarMessage(context, 'PIN must be 4 characters long');
      return;
    }
    if (isValidEmail(email)) {
      authenticate(email, pin)
          .then((checked){
        if (checked) {
          loadEvents();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                selectedIndex: 0,
              ),
            ),
          );
          return;
        } 
        utils.snackBarMessage(context, 'PIN is invalid for $email');
      });
    } else {
      utils.snackBarMessage(context, '$email is an invalid email');
    }
  }

  Future<String?> getDeviceId() async {
    deviceId = (await AppSetId().getIdentifier())!;
    return await AppSetId().getIdentifier();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    debugPrint("VALID:${emailRegex.hasMatch(email)}" );
    return emailRegex.hasMatch(email);
  }
}

void getToken() async {
  String? token = Platform.isAndroid
      ? await FirebaseMessaging.instance.getToken()
      : await FirebaseMessaging.instance.getAPNSToken();
  debugPrint('APNs Token: $token');
  ApnsToken = token!;
}
void loadEvents() async
{
  try {
    final response = await utils.getRoute('events');
    globals.totalEvents = response["events"];
    debugPrint(globals.totalEvents.toString());
  } catch (e) {
    debugPrint("error loading event data: $e");
  }
}