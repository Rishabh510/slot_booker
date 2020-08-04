import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slot_booker/userObject.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BookPage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Booker App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlineButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage())),
              child: Text('Admin Panel'),
            ),
            RaisedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage())),
              child: Text('Book a slot'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  static const url = 'https://slot-booker.firebaseio.com/slots.json';
  static const url2 = 'https://slot-booker.firebaseio.com/';
  final _t1 = TextEditingController();
  final _t2 = TextEditingController();
  String timeSlot = '5-6';
  String username;
  String email;
  final _emailFocus = FocusNode();
  final _slotFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedObject = UserObject(username: '', email: '', timeSlot: '5-6');
  var _isLoading = false;

//  Map<String, List<UserObject>> users;

  @override
  void dispose() {
    _emailFocus.dispose();
    _slotFocus.dispose();
    super.dispose();
  }

  Widget spinner(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.deepOrange,
          size: MediaQuery.of(context).size.width / 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Booker'),
      ),
      body: (_isLoading)
          ? spinner(context)
          : Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'User Name',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Please enter user name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (val) {
//                FocusScope.of(context).requestFocus(_emailFocus);
                      _emailFocus.requestFocus();
                    },
                    onSaved: (val) {
                      username = val;
                      _editedObject = UserObject(username: val, email: _editedObject.email, timeSlot: _editedObject.timeSlot);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Please enter email address';
                      }
                      return null;
                    },
                    onFieldSubmitted: (val) {
                      _slotFocus.requestFocus();
                    },
                    onSaved: (val) {
                      email = val;
                      _editedObject = UserObject(
                        username: _editedObject.username,
                        email: val,
                        timeSlot: _editedObject.timeSlot,
                      );
                    },
                  ),
                  DropdownButtonFormField(
                    value: '5-6',
                    onSaved: (val) {
                      _editedObject = UserObject(username: _editedObject.username, email: _editedObject.email, timeSlot: val);
                    },
                    items: [
                      DropdownMenuItem(
                        child: Text('5-6'),
                        value: '5-6',
                      ),
                      DropdownMenuItem(
                        child: Text('6-7'),
                        value: '6-7',
                      ),
                      DropdownMenuItem(
                        child: Text('7-8'),
                        value: '7-8',
                      ),
                    ],
                    onChanged: (val) {
                      timeSlot = val;
                      setState(() {});
                    },
                    focusNode: _slotFocus,
                    decoration: InputDecoration(labelText: 'Choose Slot'),
                  ),
                  RaisedButton(
                    onPressed: _bookSlot,
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _bookSlot() async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
//    users[_editedObject.timeSlot].add(_editedObject);
//    http.post(
//      url,
//      body: json.encode({
//        '$timeSlot': [
//          {
//            'username': username,
//            'email': email,
//            'status': true,
//          },
//        ]
//      }),
//    );
    int userCount = await slotChecker();
    if (userCount < 5) {
      http.post(
        url2 + 'slots/$timeSlot.json',
        body: json.encode({
          'username': username,
          'email': email,
          'status': true,
        }),
      );
    } else {
      print('Slot is already booked');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<int> slotChecker() async {
    try {
      final response = await http.get(url2 + 'slots/$timeSlot.json');
      final users = json.decode(response.body) as Map<String, dynamic>;
      int count = 0;
      users.forEach((key, value) {
        count++;
      });
      return count;
    } catch (error) {
      throw (error);
    }
  }
}
