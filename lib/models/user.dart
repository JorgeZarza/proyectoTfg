import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserP with ChangeNotifier {
  String id;
  String displayName;
  String photoURL;
  String email;

  UserP({ 
    this.id, 
    this.displayName, 
    this.photoURL,
    this.email,
  });

  factory UserP.fromFirestore(DocumentSnapshot userDoc) {
    Map userData = userDoc.data();
    return UserP(
      id: userDoc.id,
      displayName: userData['displayName'],
      photoURL: userData['photoURL'],
      email: userData['email']
    );
  }

  void setFromFireStore(DocumentSnapshot userDoc) {
    Map userData = userDoc.data();
    this.id = userDoc.id;
    this.displayName = userData['displayName'];
    this.photoURL = userData['photoURL'];
    this.email = userData['email'];
    notifyListeners();
  }
}