import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
//TODO push data to firebase
// TODO 0 on startup error, possibly use future builder?

void main() {
  runApp(MaterialApp(
    title: 'TapApp',
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.5,
              child: Container(
                color: Colors.lightGreen,
                child: Expanded(
                  child: FlatButton(
                    child: Text(
                      "+",
                      style: TextStyle(
                        fontSize: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.5,
              child: Container(
                color: Colors.redAccent,
                child: Expanded(
                  child: FlatButton(
                    child: Text(
                      "-",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 120,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "TapApp",
              style: TextStyle(
                color: Colors.white,
                fontSize: 100,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (
                        _,
                        a1,
                        a2,
                      ) =>
                          MainPage(),
                      transitionsBuilder:
                          (_, Animation<double> animation, __, Widget child) {
                        return new FadeTransition(
                            opacity: animation, child: child);
                      }));
              //FADE TRANSITION ADAPTED FROM https://gist.github.com/vemarav/d9f665550b339c2e061b4e811ab4c102
            },
          ),
        ],
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DatabaseReference dbRef;
  int mainNum;
  //listener for updates in database
  StreamSubscription<Event> dbSubscription;
  DatabaseError _error;
  @override
  void initState() {
    super.initState();
  }

  Future<int> getData() async {
    dbRef = FirebaseDatabase.instance.reference().child("mainNum");
    dbRef.once().then((DataSnapshot snapshot) {
      //stores the value taken from the initial snapshot of the database
      print("connected to database. value in cloud is: ${snapshot.value}");
    });
    dbRef.keepSynced(true);

    //listens for changes in database and updates mainNum accordingly
    dbSubscription = dbRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        mainNum = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
    return mainNum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.5,
              child: Container(
                color: Colors.lightGreen,
                child: Expanded(
                  child: FlatButton(
                    highlightColor: Colors.lightGreen.shade700,
                    onPressed: () {
                      print("top");
                      setState(() {
                        dbRef.set(mainNum + 1);
                      });
                    },
                    child: Text(
                      "+",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.5,
              child: Container(
                color: Colors.redAccent,
                child: Expanded(
                  child: FlatButton(
                    highlightColor: Colors.redAccent[600],
                    onPressed: () {
                      print("bottom");
                      setState(() {
                        dbRef.set(mainNum - 1);
                      });
                    },
                    child: Text(
                      "-",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 120,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FutureBuilder(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "$mainNum",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 100,
                      ),
                    );
                  }
                  else{
                    return CircularProgressIndicator();
                  }
                }),
          )
        ],
      ),
    );
  }
}
