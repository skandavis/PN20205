import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/familyMember.dart';
import 'package:NagaratharEvents/familyMemberSquare.dart';
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/material.dart';

class familyPage extends StatefulWidget {
  const familyPage({super.key});

  @override
  State<familyPage> createState() => _familyPageState();
}

class _familyPageState extends State<familyPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  static List<FamilyMember>? family;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFamily();
  }

  void loadFamily() {
    if(family != null) return;
    NetworkService().getMultipleRoute("users/family-users", forceRefresh: true).then((response) {
      if(response == null) return;
      setState(() {
        family = response.map((item) => FamilyMember.fromJson(item)).toList();
      });
    });
  }

  void createFamilyMember() async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(!utils.isValidEmail(emailController.text))
    {
      // utils.snackBarAboveMessage('${emailController.text}is an invalid email');
      // return;
      emailController.text = 'john@c.com';
      nameController.text = 'John';
      relationController.text = 'Brother';
    }
    if (nameController.text.isEmpty || emailController.text.isEmpty || relationController.text.isEmpty) {
      utils.snackBarAboveMessage('Please enter name, email and relation');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await NetworkService().postRoute({
      'email': emailController.text,
      'name': nameController.text, 
      'type':'Family', 
      'relation': relationController.text}, 
      'users',
      showAboveSnackBar: true,
    );
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      isLoading = false;
    });

    if(response.statusCode == 200){
      setState(() {
        family!.add(FamilyMember.fromJson(response.data));
      });
      utils.snackBarMessage('Family member added!', color: Colors.green);
      if(!mounted) return;
      Navigator.pop(context);
    }
  }

  void editFamilyMember(int index) async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(!utils.isValidEmail(emailController.text))
    {
      utils.snackBarAboveMessage('${emailController.text}is an invalid email');
      return;
    }
    if (nameController.text.isEmpty || emailController.text.isEmpty || relationController.text.isEmpty) {
      utils.snackBarAboveMessage('Please enter name, email and relation');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await NetworkService().patchRoute({
      "email": emailController.text,
      "name": nameController.text,
      "relation": relationController.text
      },
      'users/family-users/${family![index].id}',
      showAboveSnackBar: true
    );

    setState(() {
      isLoading = false;
    });

    if(response.statusCode == 200)
    {
      setState(() {
        family![index].name = nameController.text;
        family![index].email = emailController.text;
        family![index].relation = relationController.text;
      });
      utils.snackBarMessage('Family member updated!', color: Colors.green);
      if(!mounted) return;
      Navigator.pop(context);
    }
  }

  void createFamilyMemberDialog() {
    nameController.clear();
    emailController.clear();
    relationController.clear();
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return customDialogBox(
              title: "Add Family Member",
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      gradientTextField(
                        controller: nameController,
                        hint: "Ex: John",
                        label: "Name", 
                        icon: Icons.person,
                      ),
                      gradientTextField(
                        controller: emailController,
                        hint: "Ex: John@gmail.com",
                        label: "Email", 
                        icon: Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      gradientTextField(
                        controller: relationController,
                        hint: "Ex: Son",
                        label: "Relation", 
                        icon: Icons.groups,
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : createFamilyMember,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isLoading ? Colors.grey : globals.secondaryColor,
                          ),
                          width: 150,
                          height: 60,
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: globals.subTitleFontSize
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void editFamilyMemberDialog(int index) {
    nameController.text = family![index].name;
    emailController.text = family![index].email;
    relationController.text = family![index].relation;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Stack(
              children: [
                customDialogBox(
                  title: "Update Family Member", 
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      gradientTextField(
                        controller: nameController,
                        hint: "Ex: John",
                        label: "Name", 
                        icon: Icons.person,
                      ),
                      gradientTextField(
                        controller: emailController,
                        hint: "Ex: John@gmail.com",
                        label: "Email", 
                        icon: Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      gradientTextField(
                        controller: relationController,
                        hint: "Ex: Son",
                        label: "Relation", 
                        icon: Icons.groups,
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : (){
                          editFamilyMember(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: isLoading ? Colors.grey : globals.secondaryColor,
                          ),
                          width: 150,
                          height: 60,
                          child: Center(
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Update",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: globals.subTitleFontSize
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int count = (family == null ? 0 : family!.length) + 2;
    return Scaffold(
      backgroundColor: globals.backgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height*.075,
        title: Text(
          "Family",
          style: TextStyle(
            fontFamily: globals.titleFont,
            fontSize: globals.titleFontSize,
            color: Colors.white
          ),
        ),
        backgroundColor: globals.backgroundColor,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 25.0,
        mainAxisSpacing: 25.0,
        children: List.generate(count, (index) {
          if (index == 0) {
            return familyMemberSquare(
              familyMember: FamilyMember(id: "1", name: User.instance.name, email: User.instance.email, relation: "You"),
            );
          } else if (index == count - 1) {
            return GestureDetector(
              onTap: () {
                createFamilyMemberDialog();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 149, 235, 252), width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.add, 
                  color: Colors.white, 
                  size: 64
                ),
              ),
            );
          } else {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    editFamilyMemberDialog(index - 1);
                  },
                  child: familyMemberSquare(
                    familyMember: family![index - 1],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final response = await NetworkService().deleteRoute("users/family-users/${family![index - 1].id}");
                    if(response.statusCode != 200) return;
                    setState(() {
                      family!.removeAt(index - 1);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red,
                    ),
                    child: Icon(
                      Icons.close, 
                      color: Colors.white, 
                      size: 28
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}