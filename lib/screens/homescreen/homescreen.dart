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

  var _searchController = TextEditingController();
  FocusNode focusNode = new FocusNode();
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
            final List documentsData = documents.where((element) =>
                element['location'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
                    element['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase())
            ).toList();
            //print("\n Data : " + documents[0]['title']);
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                new Container(
                  //color: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: focusNode,
                    onChanged: (value) {
                      setState(() {
                        // if(_searchController.text.isEmpty) {
                        //   FocusScope.of(context).unfocus();
                        // }
                        _searchController.text = value;
                        _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
                      });
                      debugPrint(_searchController.text);
                    },
                    decoration: InputDecoration(
                        fillColor: Colors.white70,
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        hintText: ' Search by title & location Here',
                        filled: true,
                        suffixIcon: _searchController.text.isEmpty ? IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              debugPrint('search');
                            }) : IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              debugPrint('222');
                              setState(() {
                                FocusScope.of(context).unfocus();
                                _searchController.clear();
                              });
                            })
                    ),
                  ),
                ),
                new Expanded(
                    child: GridView.count(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 4,
                    crossAxisCount: 2,
                    children: documentsData
                        .map((doc) => GestureDetector(
                      onTap: () {
                        print("Data press " + doc['title'] + doc['usid']);
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
                            new AspectRatio(
                              aspectRatio: 18.0 / 12.0,
                              child: Image.network(
                                doc['image1'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            // new Image.network(
                            //   doc['image1'],
                            //   fit: BoxFit.cover,
                            //   width: double.infinity,
                            //   height: 120,
                            // ),
                            new Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: new Text(
                                doc['title'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                        .toList())),
              ],
            );
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
