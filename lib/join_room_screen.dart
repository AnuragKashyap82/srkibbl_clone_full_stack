import 'package:flutter/material.dart';
import 'package:srkibbl/paint_screen.dart';
import 'package:srkibbl/widgets/custom_text.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  void joinRoom(){
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaintScreen(
            data: data,
            screenFrom: 'joinRoom',
          ),
        ),
      );
    }else{
      print("null field");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Join Room",
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              hintText: "Enter your name",
              controller: _nameController,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              hintText: "Enter Room name",
              controller: _roomNameController,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: (){
              joinRoom();
            },
            child: Text(
              "Join",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                textStyle: MaterialStateProperty.all(
                    const  TextStyle(color: Colors.white)),
                minimumSize: MaterialStateProperty.all(Size(
                  MediaQuery.of(context).size.width / 2.5,
                  52,
                ))),
          ),
        ],
      ),
    );
  }
}
