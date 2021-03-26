import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'imagefullscreen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUid;
  ChatScreen({@required this.receiverUid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Message _message;
  var _formKey = GlobalKey<FormState>();
  var map = Map<String, dynamic>();
  CollectionReference _collectionReference;
  DocumentSnapshot documentSnapshot;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _senderuid;
  String receiverPhotoUrl, senderPhotoUrl, receiverName, senderName;
  StreamSubscription<DocumentSnapshot> subscription;
  File imageFile;
  FirebaseStorage _storageReference;
  TextEditingController _messageController;

  Future<User> getUID() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<DocumentSnapshot> getSenderPhotoUrl(String uid) {
    var senderDocumentSnapshot =
    FirebaseFirestore.instance.collection('users').doc(uid).get();
    return senderDocumentSnapshot;
  }

  Future<DocumentSnapshot> getReceiverPhotoUrl(String uid) {
    var receiverDocumentSnapshot =
    FirebaseFirestore.instance.collection('users').doc(uid).get();
    return receiverDocumentSnapshot;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _messageController = TextEditingController();
    getUID().then((user) {
      setState(() {
        _senderuid = user.uid;
        print("sender uid : $_senderuid");
        getSenderPhotoUrl(_senderuid).then((snapshot) {
          setState(() {
            senderPhotoUrl = snapshot['photoUrl'];
            senderName = snapshot['name'];
          });
        });
        getReceiverPhotoUrl(widget.receiverUid).then((snapshot) {
          setState(() {
            receiverPhotoUrl = snapshot['photoUrl'];
            receiverName = snapshot['name'];
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  void addMessageToDb(Message message) async {
    print("Message : ${message.message}");
    map = message.toMap();

    print("Map : ${map}");
    _collectionReference = FirebaseFirestore.instance
        .collection("messages")
        .doc(message.senderUid)
        .collection(widget.receiverUid);

    _collectionReference.add(map).whenComplete(() {
      print("Messages added to db");
    });

    _collectionReference = FirebaseFirestore.instance
        .collection("messages")
        .doc(widget.receiverUid)
        .collection(message.senderUid);

    _collectionReference.add(map).whenComplete(() {
      print("Messages added to db");
    });

    _messageController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: senderName == null || senderName == "" ? Text("Farmer App"): Text(senderName),
        ),
        body: Form(
          key: _formKey,
          child: _senderuid == null
              ? Container(
            child: CircularProgressIndicator(),
          )
              : Column(
            children: <Widget>[
              //buildListLayout(),
              ChatMessagesListWidget(),
              Divider(
                height: 20.0,
                color: Colors.black,
              ),
              ChatInputWidget(),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        ));
  }

  Widget ChatInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //   child: IconButton(
          //     splashColor: Colors.white,
          //     icon: Icon(
          //       Icons.camera_alt,
          //       color: Colors.black,
          //     ),
          //     onPressed: () {
          //       pickImage();
          //     },
          //   ),
          // ),
          Flexible(
            child: TextFormField(
              validator: (String input) {
                if (input.isEmpty) {
                  return "Please enter message";
                }
                return null;
              },
              controller: _messageController,
              decoration: InputDecoration(
                  hintText: "Enter message...",
                  labelText: "Message",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              onFieldSubmitted: (value) {
                _messageController.text = value;
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              splashColor: Colors.white,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  sendMessage();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void sendMessage() async {
    print("Inside send message");
    var text = _messageController.text;
    print(text);
    _message = Message(
        receiverUid: widget.receiverUid,
        senderUid: _senderuid,
        message: text,
        timestamp: FieldValue.serverTimestamp(),
        type: 'text');
    print(
        "receiverUid: ${widget.receiverUid} , senderUid : $_senderuid , message: $text");
    print(
        "timestamp: ${DateTime.now().millisecond}, type: ${text != null ? 'text' : 'image'}");
    addMessageToDb(_message);
  }

  Widget ChatMessagesListWidget() {
    print("SENDERUID : $_senderuid");
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(_senderuid)
            .collection(widget.receiverUid)
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  chatMessageItem(documents[index]),
              itemCount: documents.length,
            );
          }
        },
      ),
    );
  }

  Widget chatMessageItem(DocumentSnapshot documentSnapshot) {
    return buildChatLayout(documentSnapshot);
  }

  Widget buildChatLayout(DocumentSnapshot snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: snapshot['senderUid'] == _senderuid?
            MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              snapshot['senderUid'] == _senderuid
                  ? CircleAvatar(
                backgroundImage: senderPhotoUrl == null
                    ? NetworkImage('https://img.icons8.com/officel/2x/person-male.png')
                    : NetworkImage(senderPhotoUrl),
                radius: 20.0,
              )
                  : CircleAvatar(
                backgroundImage: receiverPhotoUrl == null
                    ? NetworkImage('https://img.icons8.com/officel/2x/person-male.png')
                    : NetworkImage(receiverPhotoUrl),
                radius: 20.0,
              ),
              SizedBox(
                width: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  snapshot['senderUid'] == _senderuid
                      ? new Text(
                    senderName == null ? "" : senderName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  )
                      : new Text(
                    receiverName == null ? "" : receiverName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  snapshot['type'] == 'text'
                      ? new Text(
                    snapshot['message'],
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                  )
                      : InkWell(
                    onTap: (() {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => FullScreenImage(photoUrl: snapshot['photoUrl'],)));
                    }),
                    child: Hero(
                      tag: snapshot['photoUrl'],
                      child: FadeInImage(
                        image: NetworkImage(snapshot['photoUrl']),
                        placeholder: AssetImage('assets/blankimage.png'),
                        width: 200.0,
                        height: 200.0,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

}
