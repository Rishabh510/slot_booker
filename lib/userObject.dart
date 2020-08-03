import 'package:flutter/material.dart';

class UserObject {
  final String username;
  final String email;
  final String timeSlot;
  final bool status;
  UserObject({@required this.username, @required this.email, @required this.timeSlot, this.status = false});
}

Map<String, List<UserObject>> users;

class Users {
  Map<String, List<UserObject>> users;

  void addUser(UserObject user) {
//    final newUser = UserObject(
//      username: user.username,
//      email: user.email,
//      status: user.status,
//    );
    users[user.timeSlot].add(user);
  }
}

class Slots {
  List<Users> slots;
}
