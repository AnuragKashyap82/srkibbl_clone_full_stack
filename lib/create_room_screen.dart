import 'package:flutter/material.dart';
import 'package:srkibbl/paint_screen.dart';
import 'package:srkibbl/widgets/custom_text.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();
  late String? _maxRoundsValue;
  late String? _roomSizeValue;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "occupancy": _maxRoundsValue!,
        "maxRounds": _roomSizeValue!
      };
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaintScreen(
            data: data,
            screenFrom: 'createRoom',
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
            "Create Room",
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
            height: 20,
          ),
          DropdownButton(
            focusColor: Color(0xffF5F6FA),
            onChanged: (String? value) {
              setState(() {
                _maxRoundsValue = value!;
              });
            },
            items: <String>[
              "2",
              "5",
              "10",
              "15",
            ]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ))
                .toList(),
            hint: const Text(
              "Select Max Rounds",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          DropdownButton(
            focusColor: Color(0xffF5F6FA),
            onChanged: (String? value) {
              setState(() {
                _roomSizeValue = value!;
              });
            },
            items: <String>[
              "2",
              "3",
              "4",
              "5",
              "6",
              "7",
              "8",
            ]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ))
                .toList(),
            hint: const Text(
              "Select Room Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: () {
              createRoom();
            },
            child: Text(
              "Create",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                textStyle: MaterialStateProperty.all(
                    const TextStyle(color: Colors.white)),
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
