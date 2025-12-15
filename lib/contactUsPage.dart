import 'package:NagaratharEvents/committee.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NagaratharEvents/dropDown.dart';
import 'package:NagaratharEvents/formInput.dart';
import 'package:NagaratharEvents/phoneNumberFormatter.dart';
import 'utils.dart' as utils;
import 'package:NagaratharEvents/globals.dart' as globals;

User user = User.instance;

class contactUsPage extends StatefulWidget {
  final ValueNotifier<int> isVisible;
  const contactUsPage({super.key, required this.isVisible});

  @override
  State<contactUsPage> createState() => _contactUsPageState();
}

class _contactUsPageState extends State<contactUsPage> {
  static List<committee>? committees;
  static int selectedIndex = 0;
  TextEditingController nameController = TextEditingController(text: user.name);
  TextEditingController cityController = TextEditingController(text: user.city);
  TextEditingController phoneController = TextEditingController(text: user.phone);
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode subjectFocus = FocusNode();
  FocusNode messageFocus = FocusNode();
  FocusNode departmentFocus = FocusNode();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
  }

  @override
  void dispose() {
    widget.isVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() {
    if (widget.isVisible.value == 1) {
      getCommittees();
      updateUserDetails();
    } else if(widget.isVisible.value == 0) {
      clearCommittees();
    }
  }

  clearCommittees() {
    committees = null;
  }

  void updateUserDetails() {
    setState(() {
      nameController = TextEditingController(text: user.name);
      cityController = TextEditingController(text: user.city);
      phoneController = TextEditingController(text: user.phone);
    });
  }

  Future<bool> sendMessage() async{
    final response = await NetworkService().postRoute({
      'name': nameController.text,
      'city': cityController.text,
      'phoneNumber': phoneController.text,
      "committeeId": committees![selectedIndex].id,
      'subject': subjectController.text,
      'message': messageController.text,
    },
    'contact',
    );
    return response.statusCode == 200;
  }

  void updateDepartment(int value) {
    setState(() {
      selectedIndex = value;
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
        utils.snackBarMessage('Message Sent!',color: Colors.green);
      }
      else{
        setState(() {
          loading = false;                          
        });
        utils.snackBarMessage("Unable to send Message!");
      }
    } else {
      utils.snackBarMessage('Not all fields are filled in!');
    }
  }

  void getCommittees() async{
    if(committees != null) return;
    setState(() {
      loading = true;      
    });
    NetworkService().getMultipleRoute('committees', forceRefresh: true).then((committeesSent){
      if(committeesSent == null) return;
      setState(() {
        committees = committeesSent.map((item) => committee.fromJson(item)).toList();
        loading = false;
      });
    });
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
                if(committees!=null)
                dropDown(
                  focusNode: departmentFocus,
                  options: committees!.map((item) => item.name).toList(),
                  label: "Choose the Department",
                  initialValue: committees![selectedIndex].name,
                  onChanged: updateDepartment,
                ),
                const SizedBox(
                  height: 20,
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
                formInput(
                  label: "Your Message", 
                  controller: messageController, 
                  focusNode: messageFocus, 
                  lines: 3,
                ),
                const SizedBox(
                  height: 50,
                ),
                GestureDetector(
                  onTap: submitForm,
                  child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    height: 60,
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
          if(loading)
          Container(
            color: Colors.black45,
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
