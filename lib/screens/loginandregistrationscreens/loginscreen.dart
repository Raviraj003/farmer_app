import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmer_app/screens/loginandregistrationscreens/forgotscreen.dart';
import 'package:farmer_app/screens/loginandregistrationscreens/registrationscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
// Password Toggles code start
  bool _obscureText, _autoValidate = false, _submitLoaderButton = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _username;
  String _password;


  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Stack(
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                          child: Text(
                            'Signin',
                            style:
                            TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold,),
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
                        autovalidate: _autoValidate,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'EMAIL',
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green))),
                              onChanged: (username) => setState(() {
                                _username = username;
                              }),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9@.]"))
                              ],
                              validator: (value) {
                                if(value.isEmpty) {
                                  return "Please enter email address";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green)),
                                // suffixIcon:  IconButton(
                                //   icon: Icon(
                                //     // Based on passwordVisible state choose the icon
                                //     _obscureText
                                //         ? Icons.visibility
                                //         : Icons.visibility_off,
                                //   ),
                                //   onPressed: () {
                                //     // Update the state i.e. toogle the state of passwordVisible variable
                                //     setState(() {
                                //       _obscureText = !_obscureText;
                                //     });
                                //   },
                                // ),
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              onChanged: (password) => setState(() {
                                _password = password;
                              }),
                              validator: (value) {
                                if(value.isEmpty) {
                                  return "Please enter password";
                                }
                                  return null;
                              },
                            ),
                            SizedBox(height: 5.0),
                            Container(
                              alignment: Alignment(1.0, 0.0),
                              padding: EdgeInsets.only(top: 15.0, left: 20.0),
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                    new MaterialPageRoute(builder: (context) => new ForgotScreen())),
                                child: Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              height: 40.0,
                              child: _submitLoaderButton ?
                                  CircularProgressIndicator() :
                              Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.greenAccent,
                                color: Colors.green,
                                elevation: 7.0,
                                child: GestureDetector(
                                  onTap: () {
                                    print('signin');
                                    setState(() {
                                      _submitLoaderButton = true;
                                    });
                                    loginFunction(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Row(children: <Widget>[
                              Expanded(
                                child: new Container(
                                    margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                                    child: Divider(
                                      color: Colors.black,
                                      height: 36,
                                    )),
                              ),
                              Text("OR"),
                              Expanded(
                                child: new Container(
                                    margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                                    child: Divider(
                                      color: Colors.black,
                                      height: 36,
                                    )),
                              ),
                            ]),
                            SizedBox(height: 20.0),
                            GestureDetector(
                              onTap: () async {
                                await googleSignIn().then((result) {
                                  print(result.uid);
                                  FirebaseFirestore.instance.collection("users")
                                      .doc(result.uid)
                                      .set({
                                    "uid": result.uid,
                                    "name": result.displayName,
                                    "email": result.email,
                                    "phoneNo": null,
                                    "address": null
                                  }).then((result) async {
                                    Navigator.of(context).pushReplacementNamed("/HomeScreenBottomNavigator");
                                  }).catchError((error){
                                    print(error.toString());
                                    ScaffoldMessenger
                                        .of(context)
                                        .showSnackBar(SnackBar(content: Text('Error while registration , Try Again..')));
                                  });
                                }).catchError((error) {

                                });
                              },
                              child: Center(
                                child:
                                Image.asset('assets/images/google_icon.png',
                                  height: 64, width: 64,),
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'New to User ?',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 5.0),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(builder: (context) => new SignUpPage()));
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  // Login Function start

  loginFunction(BuildContext context) async {
    if (_formKey.currentState.validate()) {
        signInFunction();
    } else {
      setState(() {
        _submitLoaderButton = false;
        _autoValidate = true;
      });

    }
  }
// Login Function end

  // Firebase Login Code

  void signInFunction() async{
    try {
      await _auth.signInWithEmailAndPassword(email: _username, password: _password).then((currentUser) {
        print(currentUser.user);
        setState(() {
          _submitLoaderButton = false;
        });
        Navigator.of(context).pushReplacementNamed("/HomeScreenBottomNavigator");
      }).catchError((error) {
        setState(() {
          _submitLoaderButton = false;
        });
        print( "erro : " + error.toString());
        ScaffoldMessenger
            .of(context)
            .showSnackBar(SnackBar(content: Text('enter valid information or register your email id.')));
      });
    } catch (e) {
      setState(() {
        _submitLoaderButton = false;
      });
      print( "erro : " + e.toString());
      ScaffoldMessenger
          .of(context)
          .showSnackBar(SnackBar(content: Text('enter valid information or register your email id.')));
    }
  }
  Future<User> googleSignIn() async {
    ScaffoldMessenger
        .of(context)
        .showSnackBar(SnackBar(content: Text('Please wait Progress...')));
    User user;

    // Step 1
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print(googleUser.displayName);
    // Step 2
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print(googleAuth.accessToken);
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print(credential.token);
    try {
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // ...
      } else if (e.code == 'invalid-credential') {
        // ...
      }
    } catch (e) {
      // ...
    }
    return user;
  }

}
