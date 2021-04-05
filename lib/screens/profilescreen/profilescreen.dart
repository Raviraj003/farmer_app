import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String _name , _address, _phoneNo, _onlineImage;
  bool _submitLoaderButton = false;
  File _profileImage;
  final picker = ImagePicker();

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        print('Image Picker :  $_profileImage');
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      getAdDetailData();
  }
  void getAdDetailData() async {
    try {
      User user = FirebaseAuth.instance.currentUser;
      DocumentReference userReference = FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot snapshot = await userReference.get();
      print(snapshot['name']);
      setState(() {
        _nameController.text = snapshot['name'];
        _addressController.text = snapshot['address'];
        _phoneController.text = snapshot['phoneNo'];
        _onlineImage = snapshot['photoUrl'];
        _name = snapshot['name'];
        _address = snapshot['address'];
        _phoneNo = snapshot['phoneNo'];
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ListView(
        shrinkWrap: true,
        children: [
          new Container(
            color: Colors.green,
            height: 240,
            child: Center(
              child: GestureDetector(
                child: _onlineImage == null ? CircleAvatar(
                  radius: 80,
                  backgroundImage: _profileImage == null ? NetworkImage('https://img.icons8.com/officel/2x/person-male.png') :
                  FileImage(_profileImage),
                  backgroundColor: Colors.white,
                ) : CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(_onlineImage),
                  backgroundColor: Colors.white,
                ),
                onTap: () async {
                  await _getImage();
                  print("press image button");
                },
              )
            ),
          ),
           new Container(
             margin: EdgeInsets.symmetric(horizontal: 20),
             child: Column(
               mainAxisSize: MainAxisSize.max,
               children: [
                 new SizedBox(
                   height: 50,
                 ),
                 new TextFormField(
                   onChanged: (name){
                     setState(() {
                       _name = name;
                     });
                   },
                   keyboardType: TextInputType.name,
                   controller: _nameController,
                   decoration: InputDecoration(
                       labelText: 'NAME',
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
                   onChanged: (phone){
                     setState(() {
                       _phoneNo = phone;
                     });
                   },
                   keyboardType: TextInputType.phone,
                   inputFormatters:[
                     LengthLimitingTextInputFormatter(10),
                   ],
                   controller: _phoneController,
                   decoration: InputDecoration(
                       labelText: 'PHONE NUMBER',
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
                   onChanged: (address) {
                     _address = address;
                   },
                   keyboardType: TextInputType.streetAddress,
                   controller: _addressController,
                   decoration: InputDecoration(
                       labelText: 'ADDRESS',
                       labelStyle: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Colors.grey),
                       focusedBorder: UnderlineInputBorder(
                           borderSide: BorderSide(color: Colors.green))),
                 ),
               ],
             ),
           ),
          new SizedBox(
            height: 60,
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
                  print('Update Profile.');
                  setState(() {
                    _submitLoaderButton = true;
                  });
                  profileUpdateFunction(context);
                },
                child: Center(
                  child: Text(
                    'UPDATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,),
                  ),
                ),
              ),
            ),
          ),
          new SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

    profileUpdateFunction(BuildContext context) async {
    String _phone = "";
    if(_phoneNo.length == 10){
      try {
        User user = FirebaseAuth.instance.currentUser;
        if(_profileImage != null) {
          String filename = basename(_profileImage.path);
          print("file path" + filename);
          Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$filename');
          print(firebaseStorageRef.toString());
          final UploadTask uploadTask = firebaseStorageRef.putFile(_profileImage);
          final TaskSnapshot downloadURL = (await uploadTask);
          final String url = await downloadURL.ref.getDownloadURL();
          print(url);
          FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .update({
            "name": _name,
            "phoneNo": _phoneNo,
            "address": _address,
            "photoUrl": url
          }).then((result) {
            print("Done");
            setState(() {
              _submitLoaderButton = false;
            });
            ScaffoldMessenger
                .of(context)
                .showSnackBar(SnackBar(content: Text('Profile Update Successfully.')));
          }).catchError((error){
            print(error.toString());
            setState(() {
              _submitLoaderButton = false;
            });
            ScaffoldMessenger
                .of(context)
                .showSnackBar(SnackBar(content: Text('Error while updating , Plz Try Again.')));
          });
        } else {
          FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .update({
            "name": _name,
            "phoneNo": _phoneNo,
            "address": _address,
          }).then((result) {
            print("Done");
            setState(() {
              _submitLoaderButton = false;
            });
            ScaffoldMessenger
                .of(context)
                .showSnackBar(
                SnackBar(content: Text('Profile Update Successfully.')));
          }).catchError((error) {
            print(error.toString());
            setState(() {
              _submitLoaderButton = false;
            });
            ScaffoldMessenger
                .of(context)
                .showSnackBar(SnackBar(
                content: Text('Error while updating , Plz Try Again.')));
          });
        }
      }catch(e) {
        print(e);
        setState(() {
          _submitLoaderButton = false;
        });
        ScaffoldMessenger
            .of(context)
            .showSnackBar(SnackBar(content: Text('Error while updating , Plz Try Again.')));
      }
    } else {
      ScaffoldMessenger
          .of(context)
          .showSnackBar(SnackBar(content: Text('Phone number must 10 digit')));
    }
  }
}
