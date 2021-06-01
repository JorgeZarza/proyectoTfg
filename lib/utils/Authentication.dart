
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_tfg/models/user.dart';

enum AuthStatus{
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated
}

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  GoogleSignInAccount _googleUser;
  UserP _user = new UserP();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthStatus _status = AuthStatus.Uninitialized;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<DocumentSnapshot> createNewUser(String email, String password,String displayName) async{
    try{
      _status = AuthStatus.Authenticating;
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;

      DocumentReference userRef = _db.collection('users').doc(user.uid);

      userRef.set({
      'uid': user.uid,
      'email': user.email,
      'lastSign': DateTime.now(),
      'photoURL': user.photoURL,
      'displayName': displayName,
    }, SetOptions(merge: true));

    DocumentSnapshot userData = await userRef.get();
    _status = AuthStatus.Authenticated;
    return userData;

    }catch(e){
      print(e.toString());
    }
    
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.Unauthenticated;
    } else {
      DocumentSnapshot userSnap = await _db
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
      _user.setFromFireStore(userSnap);
      _status = AuthStatus.Authenticated;
    }

    notifyListeners();
  }

  Future<User> googleSignIn() async {
    _status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      this._googleUser = googleUser;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        
      UserCredential authResult = await _auth.signInWithCredential(credential);
      User user = authResult.user;
      await updateUserData(user);
    } catch (e) {
      _status = AuthStatus.Uninitialized;
      notifyListeners();
      return null;
    }
  }

  Future<DocumentSnapshot> updateUserData(User user) async {
    DocumentReference userRef = _db
      .collection('users')
      .doc(user.uid);

    userRef.set({
      'uid': user.uid,
      'email': user.email,
      'lastSign': DateTime.now(),
      'photoURL': user.photoURL,
      'displayName': user.displayName,
    }, SetOptions(merge: true));

    DocumentSnapshot userData = await userRef.get();

    return userData;
  }
  

  void signOut() {
    _auth.signOut();
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
  }

  AuthStatus get status => _status;
  UserP get user => _user;
  GoogleSignInAccount get googleUser => _googleUser;

}
