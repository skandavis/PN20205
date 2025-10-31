import 'package:PN2025/customDialogBox.dart';
import 'package:PN2025/familyMemberSquare.dart';
import 'package:PN2025/gradientTextField.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/user.dart';
import 'package:PN2025/utils.dart' as utils;
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
  static List<Map<String, dynamic>> family = [];

  void createUser() {
    if(!utils.isValidEmail(emailController.text))
    {
      utils.snackBarMessage(context, '${emailController.text}is an invalid email');
      return;
    }
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      utils.snackBarMessage(context, 'Please enter both name and email');
      return;
    }
    setState(() {
      family.add({'name': nameController.text, 'email': emailController.text});
    });
    nameController.clear();
    emailController.clear();
    Navigator.of(context).pop(); // Close dialog
  }

  void createUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
          title: "Add Family Member",
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    nameController.text = family[index]['name'];
    emailController.text = family[index]['email'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return customDialogBox(
          title: "Update Family Member", 
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    family[index]['name'] = nameController.text;
                    family[index]['email'] = emailController.text;
                  });
                  nameController.clear();
                  emailController.clear();
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

  @override
  Widget build(BuildContext context) {
    int count = family.length + 2;
    return Scaffold(
      backgroundColor: globals.backgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: MediaQuery.of(context).size.height*.075,
        title: Text(
          "Family",
          style: TextStyle(
            fontFamily: GoogleFonts.almendra().fontFamily,
            fontSize: 36,
            color: Colors.white
          ),
        ),
        backgroundColor: globals.backgroundColor,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: List.generate(count, (index) {
          if (index == 0) {
            return familyMemberSquare(
              email: User.instance.email, 
              name: User.instance.name
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
                    email: family[index - 1]['email'], 
                    name: family[index - 1]['name'],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      family.removeAt(index - 1);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red,
                    ),
                    child: Icon(
                      Icons.delete, 
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
