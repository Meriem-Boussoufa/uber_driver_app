import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;

  Users({this.id, this.email, this.name, this.phone});
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    final values = dataSnapshot.value as Map<Object?, dynamic>;
    id = dataSnapshot.key;
    email = values["email"];
    name = values["name"];
    phone = values["phone"];
  }
}
