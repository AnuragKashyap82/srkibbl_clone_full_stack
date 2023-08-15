import 'package:flutter/material.dart';

class PlayerScore extends StatelessWidget {
  final List<Map> userData;

   PlayerScore(this.userData) ;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: Container(
          height: double.maxFinite,
          child: ListView.builder(
            itemCount: userData.length,
              itemBuilder: (context, index) {
            var data = userData[index].values;
            return ListTile(
              title: Text(data.elementAt(0),
                style: TextStyle(fontSize: 23, color: Colors.black),),
              trailing: Text(data.elementAt(1),
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.grey),),
            );
          }),
        ),
      ),
    );
  }
}
