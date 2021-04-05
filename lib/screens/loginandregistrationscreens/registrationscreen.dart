import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _name, _emailId, _password, _address, _phoneNo;
  bool _submitLoaderBool = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.green),
    );
    return new Scaffold(
      resizeToAvoidBottomInset: true,
        body: ListView(
            shrinkWrap: true,
            children: <
            Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                  child: Text(
                    'Signup',
                    style:
                    TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(260.0, 125.0, 0.0, 0.0),
                  child: Text(
                    ' .',
                    style: TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (name) {
                        setState(() {
                          _name = name;
                        });
                      },
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Please enter Name";
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                      ],
                      decoration: InputDecoration(
                          labelText: 'NAME ',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (email) {
                        setState(() {
                          _emailId = email;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9@.]"))
                      ],
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Please enter email address";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          // hintText: 'EMAIL',
                          // hintStyle: ,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      onChanged: (phone) {
                        setState(() {
                          _phoneNo = phone;
                        });
                      },
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Please enter phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'PHONE NUMBER ',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (address) {
                        setState(() {
                          _address = address;
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -,.()/':;*_]"))
                      ],
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Please enter address";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'ADDRESS ',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (password) {
                        setState(() {
                          _password = password;
                        });
                      },
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Please enter password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'PASSWORD ',
                          labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                      obscureText: true,
                    ),
                    SizedBox(height: 50.0),
                    Container(
                        height: 40.0,
                        child: _submitLoaderBool ?
                            CircularProgressIndicator()
                            :
                        Material(
                          borderRadius: BorderRadius.circular(20.0),
                          shadowColor: Colors.greenAccent,
                          color: Colors.green,
                          elevation: 7.0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _submitLoaderBool = true;
                              });
                              signUpFunction();
                            },
                            child: Center(
                              child: Text(
                                'SIGNUP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              )
            ),
              new SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'go back to ?',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 5.0),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
              new SizedBox(
                height: 40,
              )
          ]
        ),
    );
  }
  // Firebase registration function
  void signUpFunction() async {
    if(_formKey.currentState.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(email: _emailId, password: _password).then((value) =>
            FirebaseFirestore.instance.collection("users")
                .doc(value.user.uid)
                .set({
              "uid": value.user.uid,
              "name": _name,
              "email": _emailId,
              "phoneNo": _phoneNo,
              "address": _address
            }).then((result) async {
              setState(() {
                _submitLoaderBool = false;
              });
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Registration completed.')));
              Navigator.of(context).pushReplacementNamed("/HomeScreenBottomNavigator");

            }).catchError((error){
              print(error.toString());
              setState(() {
                _submitLoaderBool = false;
              });
              ScaffoldMessenger
                  .of(context)
                  .showSnackBar(SnackBar(content: Text('Error while registration , Try Again..')));
            })
        ).catchError((error){
          setState(() {
            _submitLoaderBool = false;
          });
          print(error.toString());
          ScaffoldMessenger
              .of(context)
              .showSnackBar(SnackBar(content: Text('Error while registration , Try Again..')));
        });
      } catch (e) {
        setState(() {
          _submitLoaderBool = false;
        });
        ScaffoldMessenger
            .of(context)
            .showSnackBar(SnackBar(content: Text('Error while registration.')));
        print(e);

        // TODO: alertdialog with error
      }
    } else {
      setState(() {
        _submitLoaderBool = false;
      });
      ScaffoldMessenger
          .of(context)
          .showSnackBar(SnackBar(content: Text('Please enter valid data.')));
    }
  }
}