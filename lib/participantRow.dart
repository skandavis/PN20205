import 'package:PN2025/activity.dart';
import 'package:PN2025/participantFieldItem.dart';
import 'package:PN2025/profileImageCircle.dart';
import 'package:flutter/material.dart';

class participantRow extends StatefulWidget {
  Activity activity;
  int index;
  participantRow({super.key, required this.activity, required this.index});

  @override
  State<participantRow> createState() => _participantRowState();
}

class _participantRowState extends State<participantRow> {

  void displayParticipantDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.only(top:25,),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white
            ),
            constraints: BoxConstraints(
              maxHeight: 400,
              maxWidth: 500
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Center(
                      child: profileImageCircle(
                        size: 150,
                        imageUrl: widget.activity.participants[widget.index].image,
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.activity.participants[widget.index].name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 32
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.activity.participants[widget.index].description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                    color: Color.fromARGB(255,31,53,76)
                  ),
                  child: Row(
                    children: [
                      participantfielditem(
                        icon: Icons.wc, 
                        title: "Gender", 
                        value: widget.activity.participants[widget.index].gender
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: const Color.fromARGB(100, 0, 0, 0),
                        width: 0,
                      ),
                      participantfielditem(
                        icon: Icons.cake, 
                        title: "Location", 
                        value: widget.activity.participants[widget.index].city
                      ),
                      VerticalDivider(
                        thickness: 2,
                        color: const Color.fromARGB(100, 0, 0, 0),
                        width: 0
                      ),
                      participantfielditem(
                        icon: Icons.cake, 
                        title: "Age", 
                        value: widget.activity.participants[widget.index].age.toString()
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        displayParticipantDetails();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          profileImageCircle(
            imageUrl: widget.activity.participants[widget.index].image,
            size: 75,
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            height: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.activity.participants[widget.index].name, 
                  style: TextStyle(color: Colors.white,fontSize: 20),
                ),
                Text(
                  widget.activity.participants[widget.index].description, 
                  style: TextStyle(color: Colors.white)
                ),
              ]
            ),
          )
        ],
      ),
    );
  }
}