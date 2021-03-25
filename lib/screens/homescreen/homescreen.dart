import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/myadscren/addetailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      bottom: true,
      maintainBottomViewPadding: true,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('adDetails').snapshots(),
        builder: (context, stream) {
          if (stream.connectionState == ConnectionState.done) {
            return Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            );
          }
          if (stream.hasData) {
            final List<DocumentSnapshot> documents = stream.data.docs;
            //print("\n Data : " + documents[0]['title']);
            return GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.all(10.0),
                mainAxisSpacing: 2,
                crossAxisSpacing: 4,
                crossAxisCount: 2,
                children: documents
                    .map((doc) => GestureDetector(
                          onTap: () {
                            print("Data press " + doc['title']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdDetailScreen(
                                        keyData: doc['title'],
                                        tempoData: null,
                                      )),
                            );
                          },
                          child: Card(
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Image.network(
                                  doc['image1'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 120,
                                ),
                                new Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: new Text(
                                    doc['title'],
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                new Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: new Text(
                                    doc['price'],
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                new SizedBox()
                              ],
                            ),
                          ),
                        ))
                    .toList());
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }
}
