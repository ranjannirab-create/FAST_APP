import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:google_sign_in/google_sign_in.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  // ইমেইল-পাসওয়ার্ড সাইনআপ
  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'profilePic': '',
          'bio': 'Clem down 🥰 Be positive 💪',
          'followersCount': 0,
          'followingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.updateDisplayName(name);
      }

      return user;
    } catch (e) {
      print("SignUp error: $e");
      return null;
    }
  }

  // ইমেইল-পাসওয়ার্ড লগইন
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // লগআউট
  Future<void> logout() async {
    
    await _auth.signOut();
  }

  // বর্তমান ইউজার স্ট্রিম
  Stream<User?> get userStream => _auth.authStateChanges();
}