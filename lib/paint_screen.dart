import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:srkibbl/final_leaderboard.dart';
import 'package:srkibbl/home_screen.dart';
import 'package:srkibbl/models/touch_points.dart';
import 'package:srkibbl/sidebar/player_scoreboard_drawer.dart';
import 'package:srkibbl/waiting_lobby_screen.dart';
import 'models/my_custom_painter.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;

  const PaintScreen({Key? key, required this.data, required this.screenFrom})
      : super(key: key);

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};

  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectorColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderBoard = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
    print(widget.data);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlack(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text(
        '_',
        style: TextStyle(fontSize: 20),
      ));
    }
  }

  //socket io client connection
  void connect() {
    _socket = IO.io('https://srkibbl-clone.onrender.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    if (widget.screenFrom == "createRoom") {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print("connected!");
      _socket.on('updateRoom', (roomData) {
        setState(() {
          renderTextBlack(roomData['word']);
          print(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('notCorrectGame', (data) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()));
      });

      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                points: Offset((point['details']['dx']).toDouble(),
                    (point['details']['dy']).toDouble()),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectorColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        }
      });

      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlack(data['word']);
                  guessedUserCtr = 0;
                  _start = 60;
                  points.clear();
                  isTextInputReadOnly = false;
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(
                  child: Text('Word was $oldWord'),
                ),
              );
            });
      });

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString()
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
        setState(() {
          _timer.cancel();
          isShowFinalLeaderBoard = true;
        });
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        Color otherColor = new Color(value);
        setState(() {
          selectorColor = otherColor;
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });
    });

    _socket.on('closeInput', (_) {
      _socket.emit('updateScore', widget.data['name']);
      setState(() {
        isTextInputReadOnly = true;
      });
    });

    _socket.on('user-disconnected', (data) {
      scoreboard.clear();
      for (int i = 0; i < data['players'].length; i++) {
        setState(() {
          scoreboard.add({
            'username': data['players'][i]['nickname'],
            'points': data['players'][i]['points'].toString()
          });
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Choose Color"),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    onColorChanged: (color) {
                      String colorString = color.toString();
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];
                      print(colorString);
                      print(valueString);
                      Map map = {
                        'color': valueString,
                        'roomName': dataOfRoom['name']
                      };
                      _socket.emit('color-change', map);
                    },
                    pickerColor: selectorColor,
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Close"))
                ],
              ));
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: PlayerScore(scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
              ? !isShowFinalLeaderBoard
                  ? Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: width,
                              height: height * 0.55,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  print(details.localPosition.dx);
                                  _socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy
                                    },
                                    'roomName': widget.data['name'],
                                  });
                                },
                                onPanStart: (details) {
                                  print(details.localPosition.dx);
                                  _socket.emit('paint', {
                                    'details': {
                                      'dx': details.localPosition.dx,
                                      'dy': details.localPosition.dy
                                    },
                                    'roomName': widget.data['name'],
                                  });
                                },
                                onPanEnd: (details) {
                                  _socket.emit('paint', {
                                    details: null,
                                    'roomName': widget.data['name']
                                  });
                                },
                                child: SizedBox.expand(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: RepaintBoundary(
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter:
                                            MyCustomPainter(pointList: points),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    selectColor();
                                  },
                                  icon: Icon(
                                    Icons.color_lens,
                                    color: selectorColor,
                                  ),
                                ),
                                Expanded(
                                    child: Slider(
                                  min: 1.0,
                                  max: 10,
                                  label: "Stroke Width $strokeWidth",
                                  activeColor: selectorColor,
                                  value: strokeWidth,
                                  onChanged: (double value) {
                                    Map map = {
                                      'value': value,
                                      'roomName': dataOfRoom['name']
                                    };
                                    _socket.emit('stroke-width', map);
                                  },
                                )),
                                IconButton(
                                  onPressed: () {
                                    _socket.emit(
                                        'clean-screen', dataOfRoom['name']);
                                  },
                                  icon: Icon(
                                    Icons.layers_clear,
                                    color: selectorColor,
                                  ),
                                ),
                              ],
                            ),
                            dataOfRoom['turn']['nickname'] !=
                                    widget.data['nickname']
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: textBlankWidget,
                                  )
                                : Center(
                                    child: Text(
                                    dataOfRoom['word'],
                                    style: TextStyle(fontSize: 30),
                                  )),
                            //Displaying messages
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    var msg = messages[index].values;
                                    return ListTile(
                                      title: Text(
                                        msg.elementAt(0),
                                        style: TextStyle(
                                            fontSize: 19,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        msg.elementAt(1),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: TextField(
                                      readOnly: isTextInputReadOnly,
                                      controller: controller,
                                      onSubmitted: (value) {
                                        if (value.trim().isNotEmpty) {
                                          Map map = {
                                            'username': widget.data['nickname'],
                                            'msg': value.trim(),
                                            'word': dataOfRoom['word'],
                                            'roomName': widget.data['name'],
                                            'guessedUserCtr': guessedUserCtr,
                                            'totalTime': 60,
                                            'timeTaken': 60 - _start,
                                          };
                                          _socket.emit('msg', map);
                                          controller.clear();
                                        }
                                      },
                                      autocorrect: false,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                          fillColor: const Color(0xffF5F5FA),
                                          filled: true,
                                          hintText: "Your Guess",
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400)),
                                      textInputAction: TextInputAction.done,
                                    )),
                              )
                            : SizedBox(),
                        SafeArea(
                            child: IconButton(
                                icon: Icon(
                                  Icons.menu,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    scaffoldKey.currentState!.openDrawer()))
                      ],
                    )
                  : FinalLeaderBoard(scoreboard, winner)
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  players: dataOfRoom['players'],
                )
          : CircularProgressIndicator(
              strokeWidth: 2,
            ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            "$_start",
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
