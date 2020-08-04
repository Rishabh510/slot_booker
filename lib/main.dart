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
  String timeSlot = '5-6';
  String username;
  String email;
  final _emailFocus = FocusNode();
  final _slotFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedObject = UserObject(username: '', email: '', timeSlot: '5-6');
  var _isLoading = false;
  var count = 0;

//  Map<String, List<UserObject>> users;

  @override
  void initState() {
    count = 0;
    timeSlot = '5-6';
    super.initState();
  }

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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
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
                    RaisedButton(
                      onPressed: _viewSlots,
                      child: Text('View Bookings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _viewSlots() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(url);
      final users = json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        _isLoading = false;
      });
      _showDialogSlots(context, users);
    } catch (error) {
      setState(() {
        _isLoading = true;
      });
      //TODO: add error dialog
      throw (error);
    }
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
    await slotChecker();
    setState(() {
      _isLoading = false;
    });
    if (count < 5) {
      _showDialogSuccess(context);
//      http.post(
//        url2 + 'slots/$timeSlot.json',
//        body: json.encode({
//          'username': username,
//          'email': email,
//          'status': true,
//        }),
//      );
    } else {
      _showDialogFail(context);
      print('Slot is already booked');
    }
  }

  Future<void> slotChecker() async {
    try {
      final response = await http.get(url2 + 'slots/$timeSlot.json');
      final users = json.decode(response.body) as Map<String, dynamic>;
      count = 0;
      users.forEach((key, value) {
        count++;
      });
    } catch (error) {
      throw (error);
    }
  }

//  _myDialog(BuildContext context) {
//    return showGeneralDialog(
//        context: context,
//        barrierDismissible: false,
//        barrierColor: Colors.deepOrangeAccent,
//        barrierLabel: 'Label',
//        pageBuilder: (context, _, _) {},
//        transitionBuilder: (context, _, _, child) {});
//  }

  _showDialogSuccess(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.4),
        useSafeArea: true,
        builder: (context) {
          return AlertDialog(
            elevation: 8,
            backgroundColor: Colors.blue[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black, width: 2),
            ),
            title: Text('Slot Available'),
            content: Text('$count/5 slots filled for the time slot: $timeSlot, Click below button to confirm slot'),
            actions: [
              RaisedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  await http.post(
                    url2 + 'slots/$timeSlot.json',
                    body: json.encode({
                      'username': username,
                      'email': email,
                      'status': true,
                    }),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Text('Book slot'),
              ),
            ],
          );
        });
  }

  _showDialogFail(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        useSafeArea: true,
        builder: (context) {
          return AlertDialog(
            elevation: 8,
            backgroundColor: Colors.blue[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black, width: 2),
            ),
            title: Text('Slot Not Available'),
            content: Text('5/5 slots filled for the time slot: $timeSlot, please choose another slot'),
            actions: [
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back'),
              ),
            ],
          );
        });
  }

  _showDialogSlots(BuildContext context, Map<String, dynamic> users) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        useSafeArea: true,
        builder: (context) {
          return Dialog(
            elevation: 8,
            backgroundColor: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black, width: 1),
            ),
            child: _showSlots(users),
          );
        });
  }

  Widget _showSlots(Map<String, dynamic> users) {
    var keys = users.keys.toList();
    List<List<TempObject>> data = [];
    for (int i = 0; i < keys.length; ++i) {
      List<TempObject> tempUser = [];
      users[keys[i]] as Map<String, dynamic>
        ..values.forEach((element) {
          tempUser.add(TempObject(element['username'], element['email']));
        });
      data.add(tempUser);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Booked Slots'),
        ListView.builder(
          itemBuilder: (context, i) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(keys[i]),
                ListView.builder(
                  itemBuilder: (context, index) {
                    var curr = data[i][index];
                    return ListTile(
                      title: Text(curr.username),
                      subtitle: Text(curr.email),
                    );
                  },
                  itemCount: data[i].length,
                ),
              ],
            );
          },
          itemCount: keys.length,
          shrinkWrap: true,
        ),
        RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go Back'),
        ),
      ],
    );
  }
}

class TempObject {
  final String username;
  final String email;

  TempObject(this.username, this.email);
}
