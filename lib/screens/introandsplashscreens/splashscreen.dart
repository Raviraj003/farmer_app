import 'dart:async';

import 'package:farmer_app/screens/introandsplashscreens/introductionscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>  with SingleTickerProviderStateMixin {
  startTime() async {
    var _duration = new Duration(seconds: 6);
    return new Timer(_duration, checkFirstSeen);
  }

  _fetchSessionAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    print(user);
    if(user == null) {
      Navigator.of(context).pushReplacementNamed("/LoginScreen");
    } else {
      Navigator.of(context).pushReplacementNamed("/HomeScreenBottomNavigator");
    }
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  // Introduction screen sharedpreference start

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      _fetchSessionAndNavigate();
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroScreen()));
    }
  }

  // Introduction screen sharedpreference end


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // splash lower logo static
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: SpinKitDualRing(
                    color: Colors.white,
                  )
              ),
            ],
          ),
          // splash main logo
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new  Hero(
                  tag: "logo_img",
                  child: new Image.asset(
                    'assets/images/buysellimage.png',
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
