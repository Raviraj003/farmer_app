import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/chatscreen/usermessagescreen.dart';
import 'package:farmer_app/screens/myadscren/addadscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class AdDetailScreen extends StatefulWidget {
  final String keyData, tempoData;
  AdDetailScreen({@required this.keyData, this.tempoData,Key key}): super(key: key);
  @override
  _AdDetailScreenState createState() => _AdDetailScreenState(this.keyData, this.tempoData);
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  final String _keyData, _tempoData;
  _AdDetailScreenState(this._keyData, this._tempoData);
  String _userId, _userUID, _titleIsId;
  PageController pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_keyData);
    getUserId();
  }

  void getUserId() async {
    User user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userUID = user.uid;
      print( " user id " + _userUID);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer App"),
        elevation: 0.0,
      ),
      body: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('adDetails').doc('$_keyData').snapshots(),
          builder: (context, stream) {
            if (stream.connectionState == ConnectionState.done) {
              return Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              );
            }
            if (stream.hasData) {
              var document = stream.data;
              _userId = document['usid'];
              _titleIsId = document['title'];
              //print("\n Data : " + documents[0]['title']);
              final List<String> imgList = [
                  document['image1'],
                  document['image2'],
                  document['image3'],
              ];
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  new Container(
                    color: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: CarouselSlider(
                          options: CarouselOptions(
                            height: 220.0,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            aspectRatio: 12 / 6,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          ),
                          items: imgList.map((item) => Container(
                            margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(item),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ).toList(),
                      )
                    ),
                    ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: [
                        AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.bounceIn,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            elevation: 8.0,
                            child: Text(" Title : " + document['title'],
                              style: TextStyle(
                                  fontSize: 28
                              ),),
                          )
                        ),
                        AnimatedContainer(
                          duration: Duration(seconds: 2),
                          curve: Curves.bounceIn,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                              margin: EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                            elevation: 6.0,
                            child: Text(" Description : " + document['description'],
                                  style: TextStyle(
                                      fontSize: 20
                                  ),
                                )
                          )
                        ),
                        AnimatedContainer(
                          duration: Duration(seconds: 3),
                          curve: Curves.bounceIn,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            elevation: 4.0,
                            child: Text(" Price : " + document['price'],
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: ListTile(
        title: _tempoData == "updateAd" ? Container(
          height: 40,
          child: GestureDetector(
            onTap: () {
              print('Edit');
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAdScreen(editData: _keyData, editKey: 'editAdDetails',)));
            },
            child: Material(
              borderRadius: BorderRadius.circular(20.0),
              shadowColor: Colors.greenAccent,
              color: Colors.green,
              elevation: 7.0,
              child: Center(
                child: Text(
                  'EDIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,),
                ),
              ),
            ),
          ),
        ) : Row (
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(child: RaisedButton(onPressed: () async {
              print(_userId);
              DocumentReference userReference = FirebaseFirestore.instance.collection('users').doc(_userId);
              DocumentSnapshot snapshot = await userReference.get();

              print(snapshot['phoneNo']);
              String phone = snapshot['phoneNo'];
              await launchURL(phone);

            },
              child: Text("Phone Number"),
              color: Colors.green,textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),)),
            new SizedBox(
              width: 10,
            ),
            Expanded(child: RaisedButton(onPressed: () async {
              if(_userUID == _userId) {
                ScaffoldMessenger
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('You can\'t chat yourself .')));
              } else {
                FirebaseFirestore.instance
                    .collection('userReceivedIds').get().then((value) {
                      if(value.docs.length == 0) {
                        FirebaseFirestore.instance
                            .collection('userReceivedIds')
                            .add({
                          "senderUid": _userId,
                          "receiverUid" : _userUID
                        });
                      } else {
                        for(int i = 0; i < value.docs.length ; i++) {
                          if(value.docs[i]['senderUid'] != _userId && value.docs[i]['receiverUid'] != _userUID
                          && value.docs[i]['senderUid'] != _userUID && value.docs[i]['receiverUid'] != _userId) {
                            FirebaseFirestore.instance
                                .collection('userReceivedIds')
                                .add({
                              "senderUid": _userId,
                              "receiverUid" : _userUID
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserMessageScreen(forShowAppBar: "showAppBr")),
                            );
                            break;
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserMessageScreen(forShowAppBar: "showAppBr")),
                            );
                            break;
                          }
                          break;
                        }
                      }
                }).catchError((error) {
                  print(error.tostring);
                });
              }
            },child: Text("Chat"),color: Colors.green,textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
              ),)),
          ],
        ),
      ),
    );
  }

  launchURL(String url) async {
    if (!url.contains('tel')) url = 'tel:$url';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


}
