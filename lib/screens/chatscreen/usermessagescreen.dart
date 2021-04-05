import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/chatscreen/chatscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserMessageScreen extends StatefulWidget {
  final String forShowAppBar;
  UserMessageScreen({@required this.forShowAppBar});
  @override
  _UserMessageScreenState createState() => _UserMessageScreenState();
}

class _UserMessageScreenState extends State<UserMessageScreen> {
  StreamSubscription<QuerySnapshot> _subscription;
  List<DocumentSnapshot> usersList;
  List<String> usersListChange = [];
  List<String> usersListChange2 = [];
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection("userReceivedIds");
  String _userUID;


  void getUserId() async {
    User user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userUID = user.uid;
      print( " user id " + _userUID);
    });
  }
  @override
  void initState() {
    super.initState();
    getUserId();
    _subscription = _collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        usersList = datasnapshot.docs;
        for(var item in usersList){
          if(item['senderUid'] == _userUID) {
            usersListChange.add(item['receiverUid']);
            print("receiver id got " + item['receiverUid']);
            continue;
          } if(item['receiverUid'] == item['senderUid']) {
            usersListChange.add(item['senderUid']);
            print("receiver id got 2 " + item['receiverUid']);
            continue;
          } if(usersListChange.length == 0) {
            for(var item in usersList) {
              if(item['receiverUid'] == _userUID) {
                usersListChange.add(item['senderUid']);
                print("receiver id got 3 " + item['senderUid']);
                continue;
              }
            }
          }
            // print(item.id);
        }

        // for(int i = 0; i< usersList.length ;i++) {
        //   if(usersList[i]['senderUid'] == _userUID) {
        //     usersListChange.add(usersList[i]['receiverUid']);
        //     print("receiver id got " + usersList[i]['receiverUid']);
        //     return;
        //   }
        // }
        print("Users List ${usersList.length}");

        print("Users List change ${usersListChange.length}");
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
      appBar: widget.forShowAppBar == "showAppBr" ?
          AppBar(
            title: Text("Farmer App"),
          )
          : null,
      body:usersListChange.length == 0
          ? Container(
        child: Center(
          child: Text("No Chat"),
        ),
      ) : Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          itemCount: usersListChange.length,
          itemBuilder: ((context, index) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(usersListChange[index]).snapshots(),
                builder: (context, strem) {
                  final DocumentSnapshot document = strem.data;
                  if(strem.hasData) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4,horizontal: 20),
                      elevation: 4.0,
                      child: ListTile(
                        // leading: CircleAvatar(
                        //   backgroundImage:
                        //   NetworkImage(document['photoUrl']),
                        // ),
                        title: Text(document['name'].toString().toUpperCase(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            )),
                        subtitle: Text(document['email'],
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        onTap: (() {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      receiverUid: document['uid'],reciverName: document['name'],)));
                        }),
                      ),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
            });
          }),
        ),
      )
    );
  }
}
