import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<User?> get userChanges => _auth.authStateChanges();
  Future<User?> signUp({required String email, required String password, String? name, String role = 'admin'}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name ?? '',
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }
  Future<User?> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }
  Future<void> signOut() => _auth.signOut();
  User? get currentUser => _auth.currentUser;
}