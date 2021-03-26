import 'dart:io';
import 'package:farmer_app/screens/chatscreen/usermessagescreen.dart';
import 'package:farmer_app/screens/homescreen/homescreen.dart';
import 'package:farmer_app/screens/myadscren/addadscreen.dart';
import 'package:farmer_app/screens/myadscren/myadscreen.dart';
import 'package:farmer_app/screens/profilescreen/profilescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreenBottomNavigator extends StatefulWidget {
  @override
  _HomeScreenBottomNavigatorState createState() => _HomeScreenBottomNavigatorState();
}

class _HomeScreenBottomNavigatorState extends State<HomeScreenBottomNavigator> {
  int bottomSelectedIndex = 0;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<bool> _onWillPop() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => exit(0),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      physics: new NeverScrollableScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        HomeScreen(),
        MyAdScreen(),
        UserMessageScreen(),
        ProfileScreen()
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildPageView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Farmer App"),
            actions: [
              IconButton(icon: Icon(Icons.logout), onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await googleSignIn.disconnect();
                await googleSignIn.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/LoginScreen', (Route<dynamic> route) => false);
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('Successfully logout.')));
              })
            ],
          ),
          body: new SafeArea(
            bottom: true,
            maintainBottomViewPadding: true,
              child: buildPageView(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.green,
            fixedColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ad_units),
                label: 'My Ad\'s',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_rounded),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: bottomSelectedIndex,
            onTap: (index) {
              bottomTapped(index);
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new Container(
              margin: EdgeInsets.symmetric(vertical: 35),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAdScreen()),
                  );
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                // elevation: 5.0,
              ),
            ),
        ),
        onWillPop: _onWillPop
    );
  }
}
