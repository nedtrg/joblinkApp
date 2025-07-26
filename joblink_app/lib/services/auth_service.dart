import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Register a new user with email, password, full name, and optional role.
  Future<String?> registerWithEmail(
    String email,
    String password,
    String fullName, {
    String role = 'worker',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return role;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth error: ${e.code} - ${e.message}");
      throw Exception(e.message); // return readable error to UI
    } catch (e) {
      print("Unexpected error during registration: $e");
      throw Exception("Registration failed. Try again.");
    }
  }

  /// Sign in using email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Sign-in error: ${e.code} - ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Unexpected login error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  /// Anonymous sign-in
  Future<void> signInAnon() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      throw Exception("Anonymous login failed");
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get the current user's role from Firestore
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['role'];
  }

  /// Getter for current user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get userStream => _auth.authStateChanges();
}
