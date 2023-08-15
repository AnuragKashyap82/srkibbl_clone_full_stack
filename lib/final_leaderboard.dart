import 'package:flutter/material.dart';

class FinalLeaderBoard extends StatelessWidget {
  final scoreboard;
  final String winner;

  FinalLeaderBoard(this.scoreboard, this.winner);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.maxFinite,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: scoreboard.length,
                itemBuilder: (context, index) {
                  var data = scoreboard[index].values;
                  return ListTile(
                    title: Text(
                      data.elementAt(0),
                      style: const TextStyle(fontSize: 23, color: Colors.black),
                    ),
                    trailing: Text(
                      data.elementAt(1),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  );
                }),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "$winner has won the game",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
