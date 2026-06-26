import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:healthify/core/services/firebase_auth_service.dart';
import 'package:healthify/core/services/firestore_service.dart';
import 'package:healthify/core/services/secure_storage_service.dart';

abstract class AuthRepository {
  Future<fb.User?> signup({required String email, required String password});
  Future<fb.User?> login({required String email, required String password});
  Future<fb.User?> signInWithGoogle();
  Future<void> logout();
  Future<fb.User?> restoreSession();
  Future<bool> isOnboardingCompleted(String uid);
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
    SecureStorageService? storageService,
  })  : _authService = authService ?? FirebaseAuthService(),
        _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? SecureStorageService();

  @override
  Future<fb.User?> signup({required String email, required String password}) async {
    final userCred = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;
    if (user != null) {
      // 1. Create initial Firestore documents
      await _firestoreService.createInitialUserDocuments(
        uid: user.uid,
        email: email,
      );
      // 2. Cache user session in Secure Storage
      await _storageService.saveUserSession(uid: user.uid);
    }
    return user;
  }

  @override
  Future<fb.User?> login({required String email, required String password}) async {
    final userCred = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;
    if (user != null) {
      // Cache user session in Secure Storage
      await _storageService.saveUserSession(uid: user.uid);
    }
    return user;
  }

  @override
  Future<fb.User?> signInWithGoogle() async {
    final userCred = await _authService.signInWithGoogle();
    if (userCred == null) return null; // user cancelled

    final user = userCred.user;
    if (user != null) {
      // Check if user onboarding document exists in Firestore
      final doc = await _firestoreService.getOnboardingDoc(user.uid);
      if (!doc.exists) {
        // First-time user, initialize their profile, onboarding, goals, settings documents
        await _firestoreService.createInitialUserDocuments(
          uid: user.uid,
          email: user.email ?? '',
        );
      }
      // Cache user session in Secure Storage
      await _storageService.saveUserSession(uid: user.uid);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await _authService.signOut();
    await _storageService.clearSession();
  }

  @override
  Future<fb.User?> restoreSession() async {
    final storedUid = await _storageService.getUid();
    final isStorableLoggedIn = await _storageService.isLoggedIn();
    final firebaseUser = _authService.currentUser;

    if (storedUid != null && isStorableLoggedIn && firebaseUser != null && firebaseUser.uid == storedUid) {
      return firebaseUser;
    }
    
    // In case Firebase is logged in but Secure Storage got cleared or vice versa, reset session to safe state.
    if (firebaseUser == null) {
      await _storageService.clearSession();
    }
    return null;
  }

  @override
  Future<bool> isOnboardingCompleted(String uid) async {
    final doc = await _firestoreService.getOnboardingDoc(uid);
    if (doc.exists && doc.data() != null) {
      return doc.data()?['completed'] ?? false;
    }
    return false;
  }
}
