import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmedia/features/auth/domain/entities/app_user.dart';
import 'package:socialmedia/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // attempt sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // fetch user details from firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // create user
      AppUser user = AppUser(
        userID: userCredential.user!.uid,
        name: userDoc['name'],
        email: email,
      );

      // return user
      return user;
    }

    // catch any errors
    catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      // attempt sign up
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create user
      AppUser user = AppUser(
        userID: userCredential.user!.uid,
        name: name,
        email: email,
      );

      // save user data in firestore
      await firebaseFirestore
          .collection("users")
          .doc(user.userID)
          .set(user.toJson());

      // return user
      return user;
    }

    // catch any errors
    catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // get current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    // if no user logged in
    if (firebaseUser == null) {
      return null;
    }

    // fetch user details from firestore
    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    
    // check if user doc exists
    if (!userDoc.exists) {
      return null;
    }

    // if user exists
    return AppUser(
      userID: firebaseUser.uid,
      name: userDoc['name'],
      email: firebaseUser.email!,
    );
  }
}
