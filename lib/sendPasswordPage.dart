import 'package:flutter/material.dart';
import 'package:app_set_id/app_set_id.dart';
import 'package:PN2025/login.dart';
import 'package:PN2025/submit.dart';
import 'package:PN2025/messageReciever.dart';

import 'utils.dart' as utils;

class sendPasswordPage extends StatefulWidget {
  String title;
  String buttonLabel;
  sendPasswordPage({super.key,required this.title, required this.buttonLabel});

  @override
  State<sendPasswordPage> createState() => _sendPasswordPageState();
}

Future<void> registerUser(String email) async {
  utils.postRoute(
    {
      // "email": email,
      "email": "viswanathanmanickam5@gmail.com",
    },
    "register",
  );
}

Future<String?> getDeviceId() async {
  // var deviceInfo = DeviceInfoPlugin();

  // if (Platform.isAndroid) {
  //   // Android device
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   return androidInfo.id; // This is the unique device ID for Android devices.
  // } else if (Platform.isIOS) {
  //   // iOS device
  //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //   return iosInfo.identifierForVendor; // This is the unique device ID for iOS devices.
  // }
  // return null;
  return await AppSetId().getIdentifier();
}
bool isValidEmail (String email) 
{
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  debugPrint("VALID:${emailRegex.hasMatch(email)}" );
  return emailRegex.hasMatch(email);
}
class _sendPasswordPageState extends State<sendPasswordPage> {
  void showDialogBox() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Email Confirmation",
              style: TextStyle(color: Colors.black),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Container(
                    child: const Text(
                      "We have sent a 4-digit PIN to your email to your email to verify your account.Please cheack it and reenter it.",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Divider(),
                  TextButton(
                    child: const Text("If you didn't get an email click here"),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => sendPasswordPage(title:"Resend\nPassword", buttonLabel:"Resend"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const loginPage(),
        ),
      );
    }
  }
  void sendPin(String email,BuildContext context) async
  {
    if (email.isEmpty ) {
      utils.snackBarMessage(context, 'Please enter email or password');
      return;
    } 
    if (isValidEmail(email)) {
      await registerUser(email).then((onvalue) 
      {
        showDialogBox();
      });
    }else {
      utils.snackBarMessage(context, '$email is an invalid email');
    }
  }
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    getDeviceId().then((onvalue) {
    });
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
                      child: Text(widget.title,
                          style: TextStyle(
                              color: Colors.white, fontSize: Theme.of(context).textTheme.displayMedium?.fontSize, height: 1)),
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
                            onSubmitted: (email) {
                              sendPin(email, context);
                            },
                            decoration: const InputDecoration(labelText: "Email"),
                            controller: email,
                          ),
                        ],
                      ),
                      submitButton(
                        text: widget.buttonLabel, 
                        onSubmit: (){
                        sendPin(email.text,context);
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Remember your password?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const loginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
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
}
