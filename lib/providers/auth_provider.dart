import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart' as app_user;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  app_user.UserModel? _user;
  app_user.UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      await _fetchUserData(firebaseUser);
    }
    notifyListeners();
  }

  Future<void> _fetchUserData(User firebaseUser) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _user = app_user.UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          role: data['role'] ?? 'General Member',
          status: data['status'] ?? 'Pending',
          phone: data['phone'],
          address: data['address'],
          bloodGroup: data['bloodGroup'],
          profession: data['profession'],
        );
      } else {
        final defaultRole = 'General Member';
        final defaultStatus = 'Pending';
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          'displayName': firebaseUser.displayName,
          'photoURL': firebaseUser.photoURL,
          'role': defaultRole,
          'status': defaultStatus,
        });
        _user = app_user.UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          role: defaultRole,
          status: defaultStatus,
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
      _user = null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> dataToUpdate) async {
    if (_user == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final userRef = firestore.collection('users').doc(_user!.uid);
      batch.update(userRef, dataToUpdate);

      final memberRef = firestore.collection('members').doc(_user!.uid);
      batch.update(memberRef, dataToUpdate);

      await batch.commit();

      await _fetchUserData(_auth.currentUser!);
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUpWithEmail(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return 'User creation failed.';
      await firebaseUser.updateDisplayName(name);

      final defaultRole = 'General Member';
      final defaultStatus = 'Pending';

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'email': firebaseUser.email,
        'displayName': name,
        'photoURL': '',
        'role': defaultRole,
        'status': defaultStatus,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print(e);
      return 'An unknown error occurred.';
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign in aborted by user.';
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print(e);
      return 'An unknown error occurred.';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}