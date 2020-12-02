import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/message_bobble.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

import 'welcome_screen.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
var messageSendingTime;

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Center(child: Text('Are you sure?')),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Do you want to go back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
                textColor: Colors.green,
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.popAndPushNamed(context, WelcomeScreen.id);
                  try {
                    _auth.signOut();
                  } catch (e) {
                    print(e);
                  }
                },
                child: new Text('Yes'),
                textColor: Colors.green,
              ),
            ],
          ),
        ) ??
        false;
  }

  final messageTextController = TextEditingController();
  String message;
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
//        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

//  void getMessages() async {
//    final messages = await _fireStore.collection('messages').getDocuments();
//    for (var message in messages.documents) {
//      print(message.data);
//    }
//  }

//  void messagesStream() async {
//    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
//      for (var message in snapshot.documents) {
//        print(message.data);
//      }
//    }
//  }

  @override
  void initState() {
    getCurrentUser();
//    messagesStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  try {
                    signOutGoogle();
                    Navigator.pop(context);
                    //_auth.signOut();
                  } catch (e) {
                    print(e);
                  }
                }),
          ],
          title: Text('⚡️Chat'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessageStreamBuilder(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          message = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        messageSendingTime = DateTime.now();
                        _fireStore.collection('messages').add({
                          'text': message,
                          'sender': loggedInUser.email,
                          'messageTime': messageSendingTime.toString(),
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _fireStore.collection('messages').orderBy('messageTime').snapshots(),
      //_fireStore.collection('messages').snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blueGrey,
            ),
          );
        } else {
          List<MessageBobble> messagesWidget = [];
          final messageStream = snapshots.data.documents.reversed;
          for (var message in messageStream) {
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final currentUser = loggedInUser.email;
            messagesWidget.add(MessageBobble(
              text: messageText,
              sender: messageSender,
              isMe: messageSender == currentUser,
            ));
          }
          return Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ListView(
                reverse: true,
                children: messagesWidget,
              ),
            ),
          );
        }
      },
    );
  }
}
