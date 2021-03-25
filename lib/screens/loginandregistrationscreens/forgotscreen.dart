import 'package:farmer_app/screens/loginandregistrationscreens/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formKey = GlobalKey<FormState>();
// Password Toggles code start
  bool _autoValidate = false, _submitLoaderButton = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                        child: Text(
                          'Forgot',
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
                          SizedBox(height: 40.0),
                          Container(
                            height: 40.0,
                            child: _submitLoaderButton ?
                                Center(
                                  child: CircularProgressIndicator(),
                                )
                                :
                            Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor: Colors.greenAccent,
                              color: Colors.green,
                              elevation: 7.0,
                              child: GestureDetector(
                                onTap: () {
                                  print('Link send');
                                  setState(() {
                                    _submitLoaderButton = true;
                                  });
                                  forgotPasswordFunction();
                                },
                                child: Center(
                                  child: Text(
                                    'Link Send',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'go to ?',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 5.0),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(builder: (context) => new LoginScreen()));
                                },
                                child: Text(
                                  'login',
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

  void forgotPasswordFunction() async {
    if(_formKey.currentState.validate()) {
      await _auth.sendPasswordResetEmail(email: _username).then((value) {
        setState(() {
          _submitLoaderButton = false;
        });
        ScaffoldMessenger
            .of(context)
            .showSnackBar(SnackBar(content: Text('Link send to $_username')));
        Navigator.of(context).pop(true);
      }).catchError((error) {
        setState(() {
          _submitLoaderButton = false;
        });
        ScaffoldMessenger
            .of(context)
            .showSnackBar(SnackBar(content: Text('Error , Try Again.')));
      });
    } else {
      setState(() {
        _submitLoaderButton = false;
      });
    }
  }
}
