import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class AddAdScreen extends StatefulWidget {
  final String editData, editKey;
  AddAdScreen({this.editData, this.editKey, Key key}): super(key: key);
  @override
  _AddAdScreenState createState() => _AddAdScreenState(this.editData, this.editKey);
}

class _AddAdScreenState extends State<AddAdScreen> {
  final String _editData, _editKey;
  _AddAdScreenState(this._editData, this._editKey);
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String _title, _description, _price, _location, _showImage1, _showImage2, _showImage3, _dbTableKey;
  File _image1, _image2, _image3;
  bool _submitLoaderButton = false, _userEnable = false;
  final picker = ImagePicker();
  var pickedFile;

  Future _pickImage() async {
    pickedFile = await picker.getImage(source: ImageSource.gallery);
  }

  Future _getImageOne() async {
    await _pickImage();
    setState(() {
      if (pickedFile != null) {
        _image1 = File(pickedFile.path);
        print('Image Picker :  $_image1');
      } else {
        print('No image selected.');
      }
    });
  }
  Future _getImageTwo() async {
    await _pickImage();
    setState(() {
      if (pickedFile != null) {
        _image2 = File(pickedFile.path);
        print('Image Picker :  $_image2');
      } else {
        print('No image selected.');
      }
    });
  }
  Future _getImageThree() async {
    await _pickImage();
    setState(() {
      if (pickedFile != null) {
        _image3 = File(pickedFile.path);
        print('Image Picker :  $_image3');
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(_editData != null) {
      setState(() {
        _userEnable = false;
      });
      getAdDetailData();
    } else {
      setState(() {
        _userEnable = true;
      });
    }
  }
  void getAdDetailData() async {
    DocumentReference userReference = FirebaseFirestore.instance.collection('adDetails').doc(_editData);
    DocumentSnapshot snapshot = await userReference.get();
    print("Read Data" + snapshot.toString());
    try {
      setState(() {
        _titleController.text = snapshot['title'];
        _descriptionController.text = snapshot['description'];
        _priceController.text = snapshot['price'];
        _locationController.text = snapshot['location'];
        _title = snapshot['title'];
        _description = snapshot['description'];
        _price = snapshot['price'];
        _location = snapshot['location'];
        _showImage1 = snapshot['image1'];
        _showImage2 = snapshot['image2'];
        _showImage3 = snapshot['image3'];
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
        appBar: AppBar(
          title: Text("Farmer App"),
          elevation: 0.0,
        ),
      body: ListView(
        shrinkWrap: true,
        children: [
          new Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 14),
            height: 130,
            color: Colors.green,
            child: GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 3,
              children: [
                _showImage1 == null ? GestureDetector(
                  onTap: _getImageOne,
                  child: Container(
                    color: Colors.black45,
                    child: _image1 == null ? Icon(Icons.add, color: Colors.white70,) : Image.file(_image1,
                    fit: BoxFit.fill,),
                  ),
                ) : Container(
                  color: Colors.black45,
                  child: Image.network(_showImage1,
                    fit: BoxFit.fill,),
                ),
                _showImage2 == null ? GestureDetector(
                    onTap: _getImageTwo,
                    child: Container(
                    color: Colors.black45,
                    child: _image2 == null ? Icon(Icons.add, color: Colors.white70,) : Image.file(_image2,
                    fit: BoxFit.fill,),
                  ),
                ) : Container(
                  color: Colors.black45,
                  child: Image.network(_showImage2,
                    fit: BoxFit.fill,),
                ),
                _showImage3 == null ? GestureDetector(
                  onTap: _getImageThree,
                  child: Container(
                    color: Colors.black45,
                    child: _image3 == null ? Icon(Icons.add, color: Colors.white70,) : Image.file(_image3,
                      fit: BoxFit.fill,),
                  ),
                ) : Container(
                  color: Colors.black45,
                  child: Image.network(_showImage3,
                    fit: BoxFit.fill,),
                ),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Card(
              elevation: 2,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  new Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        new SizedBox(
                          height: 20,
                        ),
                        new TextFormField(
                          enabled: _userEnable,
                          onChanged: (title){
                            setState(() {
                              _title = title;
                            });
                          },
                          keyboardType: TextInputType.name,
                          controller: _editData != null ? _titleController : null,
                          decoration: InputDecoration(
                              labelText: 'TITLE',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green))),
                        ),
                        new SizedBox(
                          height: 40,
                        ),
                        new TextFormField(
                          onChanged: (description){
                            setState(() {
                              _description = description;
                            });
                          },
                          keyboardType: TextInputType.text,
                          controller: _editData != null ? _descriptionController : null,
                          decoration: InputDecoration(
                              labelText: 'DESCRIPTION',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green))),
                        ),
                        new SizedBox(
                          height: 40,
                        ),
                        new TextFormField(
                          onChanged: (price) {
                            _price = price;
                          },
                          keyboardType: TextInputType.phone,
                          controller: _editData != null ? _priceController : null,
                          decoration: InputDecoration(
                              labelText: 'PRICE',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green))),
                        ),
                        new SizedBox(
                          height: 40,
                        ),
                        new TextFormField(
                          onChanged: (location) {
                            _location = location;
                          },
                          keyboardType: TextInputType.text,
                          controller: _editData != null ? _locationController : null,
                          decoration: InputDecoration(
                              labelText: 'LOCATION',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green))),
                        ),
                        new SizedBox(
                          height: 40,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 40,
                          child: _submitLoaderButton ?
                          Center(
                            child: CircularProgressIndicator(),
                          ) :
                          Material(
                            borderRadius: BorderRadius.circular(20.0),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7.0,
                            child: GestureDetector(
                              onTap: () {
                                print('Post');
                                setState(() {
                                  _submitLoaderButton = true;
                                });
                                uploadAdDetails(context);
                              },
                              child: Center(
                                child: Text(
                                  'POST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,),
                                ),
                              ),
                            ),
                          ),
                        ),
                        new SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  void uploadAdDetails(BuildContext context) async {
    try {
      print("upload inside : $_editData");
      if(_editKey == "editAdDetails") {
        print("imside if condision");
        FirebaseFirestore.instance.collection("adDetails")
            .doc(_title)
            .update({
          "title": _title,
          "description": _description,
          "price": _price,
          "location": _location

        }).then((result) {
          print("Update Done");
          setState(() {
            _submitLoaderButton = false;
          });
          ScaffoldMessenger
              .of(context)
              .showSnackBar(SnackBar(content: Text('Update Post.')));
          Navigator.of(context).pop(true);
        }).catchError((error){
          print(error.toString());
          setState(() {
            _submitLoaderButton = false;
          });
          ScaffoldMessenger
              .of(context)
              .showSnackBar(SnackBar(content: Text('Error while post, Try Again.')));
        });
      } else {
        if(_title == "" || _title == null && _description == "" || _description == null &&
        _price == "" || _price == null && _location == "" || _location == null &&
            _image1.path == null ||  _image1.path == "" && _image2.path == null || _image2.path == ""
            && _image3.path == null || _image3.path == "") {
          setState(() {
            _submitLoaderButton = false;
          });
          ScaffoldMessenger
              .of(context)
              .showSnackBar(SnackBar(content: Text('All field is required.')));
        } else {
            User user = FirebaseAuth.instance.currentUser;
            String filename = basename(_image1.path);
            String filename2 = basename(_image2.path);
            String filename3 = basename(_image3.path);
            Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('AdUploadImages/$filename');
            Reference firebaseStorageRef2 =
            FirebaseStorage.instance.ref().child('AdUploadImages/$filename2');
            Reference firebaseStorageRef3 =
            FirebaseStorage.instance.ref().child('AdUploadImages/$filename3');
            print(firebaseStorageRef.toString());
            final UploadTask uploadTask = firebaseStorageRef.putFile(_image1);
            final UploadTask uploadTask2 = firebaseStorageRef2.putFile(_image2);
            final UploadTask uploadTask3 = firebaseStorageRef3.putFile(_image3);
            final TaskSnapshot downloadURL = (await uploadTask);
            final TaskSnapshot downloadURL2 = (await uploadTask2);
            final TaskSnapshot downloadURL3 = (await uploadTask3);
            final String url = await downloadURL.ref.getDownloadURL();
            final String url2 = await downloadURL2.ref.getDownloadURL();
            final String url3 = await downloadURL3.ref.getDownloadURL();
            print(url);

            FirebaseFirestore.instance.collection("adDetails")
                .doc(_title)
                .set({
              "title": _title,
              "description": _description,
              "price": _price,
              "location": _location,
              "usid": user.uid,
              "image1": url,
              "image2": url2,
              "image3": url3
            }).then((result) {
              print("Done");
              setState(() {
                _title = null;
                _description = null;
                _price = null;
                _location = null;
                _image1 = null;
                _image2 = null;
                _image3 = null;
                _titleController.text = null;
                _descriptionController.text = null;
                _priceController.text = null;
                _locationController.text = null;
              });
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Post uploaded.')));
              Navigator.of(context).pop(true);
              setState(() {
                _submitLoaderButton = false;
              });

            }).catchError((error) {
              print(error.toString());
              setState(() {
                _submitLoaderButton = false;
              });
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Error while post, Try Again.')));
            });
          }
      }
    }catch(e) {
      setState(() {
        _submitLoaderButton = false;
      });
      print("try catch error : " + e.toString());
      ScaffoldMessenger
          .of(context)
          .showSnackBar(SnackBar(content: Text('Error while post, Try Again.')));
    }
  }
}
