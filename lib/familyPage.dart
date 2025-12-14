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

  void saveFamilyMember(int? index, Function() updateLoading) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (nameController.text.isEmpty || emailController.text.isEmpty || relationController.text.isEmpty) {
      emailController.text = 'john@c.com';
      nameController.text = 'Johnny'; 
      relationController.text = 'Brother';
      // utils.snackBarAboveMessage('Please enter name, email and relation');
      // return;
    }

    if (!utils.isValidEmail(emailController.text)) {
      utils.snackBarAboveMessage('${emailController.text} is an invalid email');
      return;
    }

    if(nameController.text.length < 5) {
      utils.snackBarAboveMessage('Name must be over 5 characters');
      return;
    }

    isLoading = true;
    updateLoading();

    final data = {
      'email': emailController.text,
      'name': nameController.text,
      'relation': relationController.text,
    };

    final response = index == null ? await NetworkService().postRoute(
      {...data, 'type': 'Family'},
      'users',
      showAboveSnackBar: true,
    ) : await NetworkService().patchRoute(
      data,
      'users/family-users/${family![index].id}',
      showAboveSnackBar: true,
    );

    isLoading = false;
    updateLoading();

    if (response.statusCode == 200) {
      setState(() {
        if (index == null) {
          family!.add(FamilyMember.fromJson(response.data));
        } else {
          family![index].name = nameController.text;
          family![index].email = emailController.text;
          family![index].relation = relationController.text;
        }
      });
      
      utils.snackBarMessage(
        index == null ? 'Family member added!' : 'Family member updated!',
        color: Colors.green,
      );
      
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void showFamilyMemberDialog({int? index}) {
    if (index == null) {
      nameController.clear();
      emailController.clear();
      relationController.clear();
    } else {
      nameController.text = family![index].name;
      emailController.text = family![index].email;
      relationController.text = family![index].relation;
    }

    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return customDialogBox(
              height: 500,
              title: index == null ? "Add Family Member" : "Update Family Member",
              body: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        onTap: () {
                          saveFamilyMember(index, () => setDialogState(() {}));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: globals.secondaryColor,
                          ),
                          width: 150,
                          height: 60,
                          child: Center(
                            child: Text(
                              index == null ? "Add" : "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: globals.subTitleFontSize,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
                showFamilyMemberDialog();
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
                    showFamilyMemberDialog(index: index - 1);
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