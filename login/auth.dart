/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
*/


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // ✅ এটি যোগ করা হয়েছে kIsWeb চেনার জন্য
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ✅ আপনার আইডি একদম পারফেক্ট আছে
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    
  );

  // ইমেইল সাইনআপ
  Future<User?> signUpWithEmail(String email, String password, String name) async {
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
          'note': '',
          'noteUpdatedAt': null,
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
        });

        await user.updateDisplayName(name);
      }

      return user;
    } catch (e) {
      print("SignUp error: $e");
      return null;
    }
  }

  // ইমেইল লগইন
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // ✅ গুগল সাইন-ইন: ব্রাউজারের পোর্টের ঝামেলা এড়ানোর ফিক্সড কোড
  Future<User?> signInWithGoogle() async {
    try {
      // আগের সেশন ক্লিয়ার করুন
      await _googleSignIn.signOut();
      
      // Google Sign-in শুরু করুন
      // 🔽 এই পরিবর্তনটুকু ওয়েবের অরিজিন ম্যাচিং এররকে বাইপাস করবে
      final GoogleSignInAccount? googleUser = kIsWeb 
          ? await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn()
          : await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ User cancelled Google sign-in');
        return null;
      }

      // অথেন্টিকেশন ডিটেইলস নিন
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Firebase credential তৈরি করুন
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase এ সাইন-ইন করুন
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      User? user = userCredential.user;
      
      // Firestore এ ইউজার সেভ/আপডেট করুন
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // নতুন ইউজার
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? googleUser.displayName ?? 'No Name',
            'email': user.email ?? googleUser.email,
            'profilePic': user.photoURL ?? googleUser.photoUrl ?? '',
            'bio': 'Clem down 🥰 Be positive 💪',
            'followersCount': 0,
            'followingCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'note': '',
            'noteUpdatedAt': null,
            'lastSeen': FieldValue.serverTimestamp(),
            'isOnline': true,
          });
        } else {
          // পুরনো ইউজার
          await _firestore.collection('users').doc(user.uid).update({
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      }
      
      print('✅ Google Sign-in successful: ${user?.email}');
      return user;
      
    } catch (e) {
      print('❌ Google Sign-in Error: $e');
      return null;
    }
  }

  // লগআউট
  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
    
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // বর্তমান ইউজার স্ট্রিম
  Stream<User?> get userStream => _auth.authStateChanges();
}