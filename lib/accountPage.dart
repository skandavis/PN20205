import 'package:NagaratharEvents/homePage.dart';
import 'package:NagaratharEvents/imageLoader.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/phoneNumberFormatter.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/formInput.dart';
import 'package:NagaratharEvents/messageReciever.dart';
import 'package:app_set_id/app_set_id.dart';
import 'utils.dart' as utils;
import 'package:NagaratharEvents/globals.dart' as globals;

String deviceID = "";
User user = User.instance;

class accountPage extends StatefulWidget {
  bool firstTime;
  accountPage({super.key, required this.firstTime});

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
              fontFamily: globals.titleFont,
              fontSize: globals.titleFontSize,
              color: Colors.white
            ),
          ),
          backgroundColor: globals.backgroundColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              imageLoader(
                fileName: "${user.name}Profile.jpg",
                buttonSize: 25,
                size: 100,
                circle: true,
                imageRoute: user.photo,
                uploadRoute: "users/photo",
                deleteRoute: "users/photo",
                onDelete: () {
                  user.photo = null;
                },
                onUpload: (file) {
                  user.photo = file.path;                    
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: globals.subTitleFontSize,
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
                        inputType: TextInputType.text
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
                      utils.snackBarMessage("Please fill all the fields!");
                      return;
                    }
                    if(controllers[1].text.length != 12){
                      utils.snackBarMessage("Please enter a valid phone number!");
                      return;
                    }
                  }
                  Map<String, dynamic> data = {
                    "name": controllers[0].text,
                    "phoneNumber":controllers[1].text,
                    "city": controllers[2].text,
                  };
                  final response = await  NetworkService().patchRoute(data, 'users');
                  if(response.statusCode != 200) return;
                  user.setPersonalInfo(data);
                  utils.snackBarMessage("Account Details Updated!",color: Colors.green);
                  if(widget.firstTime){
                    user.firstTime = false;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  homePage(),));
                  }else{
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 250,
                  height: 70,
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
                          fontSize: globals.subTitleFontSize,
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
