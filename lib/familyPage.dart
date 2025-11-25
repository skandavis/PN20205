import 'package:NagaratharEvents/customDialogBox.dart';
import 'package:NagaratharEvents/familyMember.dart';
import 'package:NagaratharEvents/familyMemberSquare.dart';
import 'package:NagaratharEvents/gradientTextField.dart';
import 'package:NagaratharEvents/globals.dart' as globals;
import 'package:NagaratharEvents/networkService.dart';
import 'package:NagaratharEvents/user.dart';
import 'package:NagaratharEvents/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    if(family != null) return;
    loadFamily();
  }
  void createUser() {
    if(!utils.isValidEmail(emailController.text))
    {
      utils.snackBarMessage(context, '${emailController.text}is an invalid email');
      emailController.text = "sskandamani@gmail.com";
      // return;
    }
    if (nameController.text.isEmpty || emailController.text.isEmpty || relationController.text.isEmpty) {
      utils.snackBarMessage(context, 'Please enter name, email and relation');
      nameController.text = "Cornelius Cornwallus Coconut";
      emailController.text = "sskandamani@gmail.com";
      relationController.text = "Son";
      // return;
    }
    NetworkService().postRoute({
      'email': emailController.text,
      'name': nameController.text, 
      'type':'Family', 
      'relation': relationController.text}, 
      'users').then((response) {
        setState(() {
          family!.add(FamilyMember.fromJson(response.data)); // Add the new user to the list of family members.response.data);
        });
      });
    nameController.clear();
    emailController.clear();
    relationController.clear();
    Navigator.of(context).pop(); // Close dialog
  }

  void createUserDialog() {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return customDialogBox(
          title: "Add Family Member",
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
                onTap: () {
                  createUser();
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
                      "Add",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void editUser(int index) {
    nameController.text = family![index].name;
    emailController.text = family![index].email;
    relationController.text = family![index].relation;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
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
                onTap: () {
                  setState(() {
                    family![index].name = nameController.text;
                    family![index].email = emailController.text;
                    family![index].relation = emailController.text;
                  });
                  NetworkService().patchRoute({
                    "email": emailController.text,
                    "name": nameController.text,
                    "relation": relationController.text
                    },
                    'users/family-users/${family![index].id}'
                  );
                  nameController.clear();
                  emailController.clear();
                  relationController.clear();
                  Navigator.of(context).pop();
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
                      "Update",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void loadFamily() {
    NetworkService().getMultipleRoute("users/family-users", context, forceRefresh: true).then((response) {
      if(response == null) return;
      setState(() {
        family = response.map((item) => FamilyMember.fromJson(item)).toList();
      });
    });
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
            fontFamily: GoogleFonts.arvo().fontFamily,
            fontSize: 36,
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
                createUserDialog();
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
                    editUser(index - 1); // Open edit dialog for this user
                  },
                  child: familyMemberSquare(
                    familyMember: family![index - 1],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    NetworkService().deleteRoute("users/family-users/${family![index - 1].id}");
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
