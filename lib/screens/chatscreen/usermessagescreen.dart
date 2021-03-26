import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserMessageScreen extends StatefulWidget {
  @override
  _UserMessageScreenState createState() => _UserMessageScreenState();
}

class _UserMessageScreenState extends State<UserMessageScreen> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot> _subscription;
  List<DocumentSnapshot> usersList;
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection('messages');

  @override
  void initState() {
    super.initState();
    _subscription = _collectionReference.snapshots().listen((dataSnapshot) {
      setState(() {
        usersList = dataSnapshot.docs;
        print("Users List ${usersList.length}");
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // body: ListView.builder(
      //         padding: EdgeInsets.all(10.0),
      //         itemBuilder: (context, index) =>
      //             Container(
      //               child: Text(usersList[index].id),
      //             ),
      //         itemCount: usersList.length,
      //       )
      body: Center(
        child: Text("Messages screen"),
      ),
    );
  }
}
