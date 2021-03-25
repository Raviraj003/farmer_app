import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/myadscren/addadscreen.dart';
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
  String _userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_keyData);
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: Text("Title : " + document['title'],
                            style: TextStyle(
                                fontSize: 28
                            ),),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text("Description : " + document['description'],
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                          child: Text("Price : " + document['price'],
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
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
        ) : Row(
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
            Expanded(child: RaisedButton(onPressed: () {

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
