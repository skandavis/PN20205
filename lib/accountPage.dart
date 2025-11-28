
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/profileImageCircle.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/phoneNumberFormatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/formInput.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:app_set_id/app_set_id.dart';
import 'utils.dart' as utils;
import 'package:NagaratharEvents/globals.dart' as globals;

String deviceID = "";
User user = User.instance;

class accountPage extends StatefulWidget {
  const accountPage({super.key});

  @override
  State<accountPage> createState() => _accountPageState();
}

class _accountPageState extends State<accountPage> {
  List<String> labels = ["Name","Phone","City"];
  List<TextEditingController> controllers = [
    TextEditingController(text: user.name),
    TextEditingController(text: user.phone),
    TextEditingController(text: user.city),
  ];
  List<FocusNode> inputFocusNodes = [FocusNode(),FocusNode(),FocusNode()];
  void getDeviceId() async {
    deviceID = (await AppSetId().getIdentifier())!;
  }

  @override
  void initState() {
    super.initState();
    getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return messageReciever(
      body: Scaffold(
        backgroundColor: globals.backgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: MediaQuery.of(context).size.height*.075,
          title: Text(
            "Account",
            style: TextStyle(
              fontFamily: GoogleFonts.arvo().fontFamily,
              fontSize: 36,
              color: Colors.white
            ),
          ),
          backgroundColor: globals.backgroundColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              profileImageCircle(
                size: 75,
                imageUrl:user.photo,
                uploadRoute:"users/photo",
                onImageChanged: (file) {
                  setState(() {
                    user.photo = file.path;
                  });
                },
              ),
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
                child:  ListView.builder(itemCount: inputFocusNodes.length,itemBuilder: (context, index){
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
                        inputType: index == 1?TextInputType.phone:TextInputType.text
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
                onTap: () async{
                  for(TextEditingController controller in controllers){
                    if(controller.text.isEmpty){
                      utils.snackBarMessage(context, "Please fill all the fields!",color: Colors.red);
                      return;
                    }
                  }
                  final response = await  NetworkService().patchRoute({
                    // "email": "viswanathanmanickam5@gmail.com",
                    "name": controllers[0].text,
                    "phoneNumber":controllers[1].text,
                    "city": controllers[2].text,

                  }, 'users');
                  if(response.statusCode != 200) return;
                  user.setPersonalInfo({
                    'name':controllers[0].text,
                    'phone':controllers[1].text,
                    'city':controllers[2].text
                  });
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
