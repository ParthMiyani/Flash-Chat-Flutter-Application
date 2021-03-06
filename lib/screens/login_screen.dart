import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool emailValidator = false;
  bool passWordValidator = false;
  bool _showSpinner = false;
  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  FocusNode _focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: WelcomeScreen.id,
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    controller: emailTextFieldController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email',
                      errorText:
                          emailValidator ? 'Email Can\'t Be Empty' : null,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: passwordTextFieldController,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your password',
                      errorText:
                          passWordValidator ? 'Password Can\'t Be Empty' : null,
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Hero(
                    tag: LoginScreen.id,
                    child: RoundedButton(
                      colour: Colors.lightBlueAccent,
                      title: 'Log In',
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _focusNode.unfocus();
                        setState(() {
                          if (emailTextFieldController.text.isEmpty) {
                            emailValidator = true;
                            email = null;
                          } else {
                            emailValidator = false;
                          }
                          if (passwordTextFieldController.text.isEmpty) {
                            passWordValidator = true;
                            password = null;
                          } else {
                            passWordValidator = false;
                          }
                        });

                        emailTextFieldController.clear();
                        passwordTextFieldController.clear();
                        setState(() {
                          _showSpinner = true;
                        });
                        try {
                          final loggedInUser =
                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);
                          if (loggedInUser != null) {
                            setState(() {
                              _showSpinner = false;
                            });
                            Navigator.pushNamed(context, ChatScreen.id);
                          }
                        } catch (e) {
                          setState(() {
                            _showSpinner = false;
                          });
                          if (e.code == 'ERROR_INVALID_EMAIL') {
                            Toast.show('Please enter valid Email.', context,
                                duration: 4, gravity: Toast.BOTTOM);
                          } else if (e.code == 'ERROR_USER_NOT_FOUND') {
                            Toast.show('User not found.', context,
                                duration: 4, gravity: Toast.BOTTOM);
                          } else if (e.code == 'FirebaseException') {
                            Toast.show('Please check you Internet connection.',
                                context,
                                duration: 4, gravity: Toast.BOTTOM);
                          } else {
                            Toast.show(
                                'Please check your credentials.', context,
                                duration: 4, gravity: Toast.BOTTOM);
                          }
                          print(e);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
