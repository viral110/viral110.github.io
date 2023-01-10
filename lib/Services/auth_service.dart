import 'package:chat_fire_flutter/Helper/shared_helper.dart';
import 'package:chat_fire_flutter/Services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Login

  Future loginUserWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){

        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  // Register

  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        await DataBaseService(uid : user.uid).savingUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  // Logout

  Future logoutApplication () async {
    try {
      await firebaseAuth.signOut();
      await HelperFunctions.setTheLoggedInStatus(false);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}
