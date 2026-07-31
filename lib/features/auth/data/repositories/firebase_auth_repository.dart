import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

/// The only place in the app allowed to talk to Firebase Auth / the
/// `users` Firestore collection for authentication purposes.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  bool _googleSignInReady = false;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _fetchProfile(user.uid);
      } on AuthFailure {
        return null;
      }
    });
  }

  Future<AppUserModel> _fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      throw const AuthFailure(
        'We could not find your profile. Please contact support.',
      );
    }
    return AppUserModel.fromMap(uid, doc.data()!);
  }

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInReady) return;
    await _googleSignIn.initialize();
    _googleSignInReady = true;
  }

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String district,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(name);

      final profile = AppUserModel(
        id: uid,
        name: name,
        email: email.trim(),
        role: role,
        phone: phone,
        district: district,
        rating: 0,
      );
      await _users.doc(uid).set(profile.toMap());
      return profile;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthMessage(e));
    } on FirebaseException catch (e) {
      throw AuthFailure(_friendlyFirestoreMessage(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'Something went wrong while registering. Please try again.',
      );
    }
  }

  @override
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _fetchProfile(credential.user!.uid);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthMessage(e));
    } on FirebaseException catch (e) {
      throw AuthFailure(_friendlyFirestoreMessage(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'Something went wrong while signing in. Please try again.',
      );
    }
  }

  @override
  Future<AppUser> signInWithGoogle({required UserRole role}) async {
    try {
      await _ensureGoogleSignInReady();
      final googleUser = await _googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final fbUser = userCredential.user!;

      final existing = await _users.doc(fbUser.uid).get();
      if (existing.exists) {
        return AppUserModel.fromMap(fbUser.uid, existing.data()!);
      }

      final profile = AppUserModel(
        id: fbUser.uid,
        name:
            fbUser.displayName ?? googleUser.displayName ?? 'Soko Direct user',
        email: fbUser.email ?? googleUser.email,
        role: role,
        phone: fbUser.phoneNumber,
        district: null,
        rating: 0,
      );
      await _users.doc(fbUser.uid).set(profile.toMap());
      return profile;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Sign-in was cancelled.');
      }
      throw const AuthFailure('Google sign-in failed. Please try again.');
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_friendlyAuthMessage(e));
    } on FirebaseException catch (e) {
      throw AuthFailure(_friendlyFirestoreMessage(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'Something went wrong with Google sign-in. Please try again.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Not signed in with Google — nothing to clean up.
    }
    await _auth.signOut();
  }

  String _friendlyAuthMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _friendlyFirestoreMessage(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'permission-denied':
        return 'You do not have permission to do that.';
      default:
        return 'We could not reach the server. Please try again.';
    }
  }
}
