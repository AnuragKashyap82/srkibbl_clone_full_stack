import 'package:flutter/material.dart';
import 'package:srkibbl/create_room_screen.dart';
import 'package:srkibbl/join_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create/Join a room to play",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>const CreateRoomScreen()));
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      textStyle: MaterialStateProperty.all(
                         const  TextStyle(color: Colors.white)),
                      minimumSize: MaterialStateProperty.all(Size(
                        MediaQuery.of(context).size.width / 2.5,
                        52,
                      ))),
                  child: const Text(
                    "Create",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>const JoinRoomScreen()));
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      textStyle: MaterialStateProperty.all(
                         const  TextStyle(color: Colors.white)),
                      minimumSize: MaterialStateProperty.all(Size(
                        MediaQuery.of(context).size.width / 2.5,
                        52,
                      ))),
                  child: const Text(
                    "Join",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
