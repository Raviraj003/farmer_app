import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/myadscren/addadscreen.dart';
import 'package:farmer_app/screens/myadscren/addetailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAdScreen extends StatefulWidget {
  @override
  _MyAdScreenState createState() => _MyAdScreenState();
}
class _MyAdScreenState extends State<MyAdScreen> {
  String _userUID = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      body: StreamBuilder<QuerySnapshot>(
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
                final List documentsData = documents.where((element) => element['usid'] == _userUID).toList();
                //print("\n Data : " + documents[0]['title']);
                return documentsData.isEmpty ? Center(
                  child: Text("Add Ad"),
                ) : GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  addRepaintBoundaries: true,
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 4,
                    crossAxisCount: 2,

                  ),
                  itemCount: documentsData.length,
                  itemBuilder: (context , index) {
                    return  GestureDetector(
                      onTap: () {
                        print("Data press " + documentsData[index]['title']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdDetailScreen(keyData: documentsData[index]['title'], tempoData: 'updateAd',)),
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(seconds: 2),
                        curve: Curves.bounceIn,
                        child: Card(
                          elevation: 6.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 18.0 / 12.0,
                                child: Image.network(
                                  documentsData[index]['image1'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // r
                              new Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                child:  new Text(documentsData[index]['title'],
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),),
                              ),
                              new Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                child: new Text(documentsData[index]['price'],
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),),
                              ),
                              new SizedBox()
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );
              } else if(stream.hasError) {
                return Center(
                  child: Text("Add Ad's"),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
      ),
    );
  }
}
