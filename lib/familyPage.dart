import 'package:PN2025/gradientTextField.dart';
import 'package:PN2025/globals.dart' as globals;
import 'package:PN2025/user.dart';
import 'package:PN2025/utils.dart' as utils;
import 'package:flutter/material.dart';

class familyPage extends StatefulWidget {
  const familyPage({super.key});

  @override
  State<familyPage> createState() => _familyPageState();
}

class _familyPageState extends State<familyPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  List<Map<String, dynamic>> family = [];

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

void editUser(int index) {
  // Pre-fill the controllers
  nameController.text = family[index]['name'];
  emailController.text = family[index]['email'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        constraints: BoxConstraints(
            maxHeight: 400,
            maxWidth: 500
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.white
          ),
          child: Column(
            children: [
              Container(
                height: 75,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  color: Color.fromARGB(255,31,53,76)
                ),
                child: Center(
                  child: Text(
                    "Update Family Member", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 28
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                height: 325,
                child: Column(
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
              ),
            ],
          ),
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
        title: Text(
          "Family",
          style: TextStyle(
            color: Colors.white,
            fontSize: Theme.of(context).textTheme.displaySmall?.fontSize,
          ),
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: List.generate(count, (index) {
          if (index == 0) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: globals.iceBlue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.person, size: 64, color: globals.backgroundColor),
                  Text(User.instance.name,
                      style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
                  Text(User.instance.email,
                      style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
                ],
              ),
            );
          } else if (index == count - 1) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      constraints: BoxConstraints(
                          maxHeight: 400,
                          maxWidth: 500
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          color: Colors.white
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 75,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                color: Color.fromARGB(255,31,53,76)
                              ),
                              child: Center(
                                child: Text(
                                  "Add Family Member", 
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontSize: 28
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              height: 325,
                              child: Column(
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 149, 235, 252), width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 64),
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
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: globals.iceBlue,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.person, size: 64, color: globals.backgroundColor),
                        Text(family[index - 1]['name'],
                            style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
                        Text(family[index - 1]['email'],
                            style: TextStyle(color: globals.backgroundColor, fontSize: 14)),
                      ],
                    ),
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
                      color: Colors.redAccent,
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 28),
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
