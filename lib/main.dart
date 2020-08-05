import 'dart:convert';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slot_booker/userObject.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slot Booker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
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
  String username;
  String email;
  final _emailFocus = FocusNode();
  final _slotFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedObject = UserObject(username: '', email: '', timeSlot: '5-5:00-6:00 pm');
  var _isLoading = false;
  var count = 0;
  List<String> timeSlots = ['5:00-6:00 pm', '6:00-7:00 pm', '7:00-8:00 pm'];
  String timeSlot = '5:00-6:00 pm';
  ConfettiController _controllerCenter;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    count = 0;
    timeSlot = '5:00-6:00 pm';
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
    super.initState();
  }

//  @override
//  void didChangeDependencies() {
//    _controllerCenter = ConfettiController(duration: const Duration(seconds: 3));
//    super.didChangeDependencies();
//  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _emailFocus.dispose();
    _slotFocus.dispose();
    super.dispose();
  }

  Widget spinner(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: SpinKitChasingDots(
          color: Colors.deepOrange,
          duration: Duration(milliseconds: 1000),
          size: MediaQuery.of(context).size.width / 2,
        ),
      ),
    );
  }

  InputDecoration decorator(String label, int i) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 20),
      icon: (i == 2) ? Icon(Icons.email) : (i == 3) ? Icon(Icons.access_time) : Icon(Icons.account_circle),
      hintText: (i == 2) ? 'example@gmail.com' : (i == 3) ? 'Choose Slot' : 'UsernameABC',
      border: OutlineInputBorder(
        borderSide: BorderSide(),
        borderRadius: BorderRadius.circular(16),
      ),
      filled: true,
//      fillColor: Colors.black.withOpacity(0.1),
    );
  }

  List<Color> _colorList = [
    Colors.red.withOpacity(0.5),
    Colors.yellow.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        title: TypewriterAnimatedTextKit(
          repeatForever: true,
          isRepeatingAnimation: true,
          speed: Duration(seconds: 2),
          onTap: () {},
          text: [
            "Slot Booking Application",
          ],
          textAlign: TextAlign.center,
          alignment: AlignmentDirectional.center,
        ),
      ),
      body: (_isLoading)
          ? spinner(context)
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _colorList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextFormField(
                                  decoration: decorator('User Name', 1),
                                  textCapitalization: TextCapitalization.words,
                                  cursorColor: Colors.deepOrange,
                                  cursorWidth: 8,
                                  cursorRadius: Radius.circular(8),
                                  textInputAction: TextInputAction.next,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Please enter user name';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (val) {
                                    _emailFocus.requestFocus();
                                  },
                                  onSaved: (val) {
                                    username = val;
                                    _editedObject = UserObject(
                                      username: val,
                                      email: _editedObject.email,
                                      timeSlot: _editedObject.timeSlot,
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextFormField(
                                    decoration: decorator('Email', 2),
                                    cursorColor: Colors.deepOrange,
                                    cursorWidth: 8,
                                    cursorRadius: Radius.circular(8),
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
                                ),
                                DropdownButtonFormField(
                                  elevation: 16,
                                  hint: Text('choose time slot'),
                                  dropdownColor: Colors.blue[100],
                                  value: timeSlots[0],
                                  onSaved: (val) {
                                    _editedObject = UserObject(username: _editedObject.username, email: _editedObject.email, timeSlot: val);
                                  },
                                  items: List.generate(
                                    timeSlots.length,
                                    (index) => DropdownMenuItem(
                                      child: Text(timeSlots[index]),
                                      value: timeSlots[index],
                                    ),
                                  ),
                                  onChanged: (val) {
                                    timeSlot = val;
                                    setState(() {});
                                  },
                                  focusNode: _slotFocus,
                                  decoration: decorator('Choose Slot', 3),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: RaisedButton(
                                    onPressed: _bookSlot,
                                    color: Colors.deepOrange,
                                    padding: EdgeInsets.all(12),
                                    elevation: 16,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: myText('Submit'),
                                  ),
                                ),
                                OutlineButton(
                                  onPressed: _viewSlots,
                                  child: myText('View Bookings'),
                                  color: Colors.deepOrange,
                                  padding: EdgeInsets.all(12),
                                  highlightColor: Colors.deepOrange.withOpacity(0.5),
                                  highlightElevation: 16,
                                  borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Contact: ',
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              RotateAnimatedTextKit(
                                onTap: () {},
                                repeatForever: true,
                                duration: Duration(seconds: 20),
                                displayFullTextOnTap: true,
                                text: [
                                  "Rishabh Raizada",
                                  "rishabh5102000@gmail.com",
                                  "+91 8860932771",
                                ],
                                textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
                  width: MediaQuery.of(context).size.width,
                  child: Align(
                    alignment: Alignment.center,
                    child: ConfettiWidget(
                      confettiController: _controllerCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      // don't specify a direction, blast randomly
                      shouldLoop: false,
                      // start again as soon as the animation is finished
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                      numberOfParticles: 50,
                      gravity: 0.2,
                    ),
                  ),
                ),
              ],
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
        _isLoading = false;
      });
      print(error);
      _showDialogError(context, error);
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
    if (count < 5) {
      _showDialogSuccess(context);
    } else {
      _showDialogFail(context);
    }
  }

  Future<void> slotChecker() async {
    try {
      final response = await http.get(url2 + 'slots/$timeSlot.json');
      final users = json.decode(response.body) as Map<String, dynamic>;
      setState(() {
        _isLoading = false;
      });
      count = 0;
      users.forEach((key, value) {
        count++;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error);
      _showDialogError(context, error);
      throw (error);
    }
  }

  _showDialogError(BuildContext context, dynamic error) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        useSafeArea: true,
        builder: (context) {
          return SimpleDialog(
            elevation: 8,
            backgroundColor: Colors.blue[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black, width: 2),
            ),
            title: Text('ERROR'),
            children: [
              SimpleDialogOption(
                child: Text(error.toString()),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

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
                  Future.delayed(Duration(milliseconds: 500)).then((value) {
                    _controllerCenter.play();
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: myText('Slot booked successfully'),
                      ),
                      behavior: SnackBarBehavior.floating,
                      elevation: 16,
                      backgroundColor: Colors.deepOrange,
                    ));
                  });
                },
                color: Colors.deepOrange,
                padding: EdgeInsets.all(12),
                elevation: 16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: myText('Book Slot'),
              ),
            ],
          );
        });
  }

  Widget myText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, offset: Offset(-2, 2))],
      ),
    );
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
            backgroundColor: Colors.blue[100],
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
                color: Colors.deepOrange,
                padding: EdgeInsets.all(12),
                elevation: 16,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: myText('Go Back'),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booked Slots',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontStyle: FontStyle.italic,
              ),
            ),
            ListView.builder(
              itemBuilder: (context, i) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '${keys[i]}',
                        style: TextStyle(
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dashed,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepOrange,
                          shadows: [Shadow(color: Colors.black, offset: Offset(-1, 1))],
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Table(
                        children: List.generate(data[i].length, (index) {
                          var curr = data[i][index];
                          return TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                curr.username,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                curr.email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'TRUE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ]);
                        }),
                        border: TableBorder.all(color: Colors.deepOrange, width: 2),
                      ),
                    ),
                  ],
                );
              },
              itemCount: keys.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.deepOrange,
              padding: EdgeInsets.all(12),
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: myText('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class TempObject {
  final String username;
  final String email;

  TempObject(this.username, this.email);
}
