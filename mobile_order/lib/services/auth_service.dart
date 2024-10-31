//file: \lib\services\auth_service.dart

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import './socket_service.dart';

class AuthService extends GetxService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Rx<User?> currentUser = Rx<User?>(null);
  // final SocketService _socketService = Get.find<SocketService>();
  Future<void> init() async {
    print('AuthService init started');
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    // 초기 상태 설정
    _onAuthStateChanged(_firebaseAuth.currentUser);
    print('AuthService init completed');
  }

  @override
  void onInit() {
    super.onInit();
    print('AuthService onInit called');
    init();
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    print(
        'Auth state changed: ${firebaseUser != null ? 'User logged in' : 'User logged out'}');
    if (firebaseUser != null) {
      currentUser.value = User.fromFirebaseUser(firebaseUser);
      await _updateUserToken(firebaseUser);
      print('Current user set: ${currentUser.value?.email}');
    } else {
      currentUser.value = null;
      await _storage.delete(key: 'auth_token');
      print('Current user cleared');
    }
  }

  Future<bool> _saveUserToMongoDB(firebase_auth.User user) async {
    try {
      final String? token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.userAuth}/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        }),
      );

      if (response.statusCode == 200) {
        print('User saved to MongoDB successfully');
        return true;
      } else {
        print('Failed to save user to MongoDB: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving user to MongoDB: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google Sign In process');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign In was canceled by the user');
        return false;
      }

      print('Got Google Sign In account: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Got Google Auth token: ${googleAuth.accessToken}');
      print('Got Google ID token: ${googleAuth.idToken}');

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential, attempting to sign in');
      final firebase_auth.UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);
      final firebase_auth.User? user = authResult.user;

      if (user != null) {
        print('Successfully signed in with Google: ${user.displayName}');
        await _saveUserToMongoDB(user);
        return true;
      } else {
        print('Failed to sign in with Google: User is null');
        return false;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      if (e is firebase_auth.FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      }
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final authResult =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final user = authResult.user;

      if (user != null) {
        print('Successfully signed in with Apple: ${user.displayName}');

        await _saveUserToMongoDB(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _storage.delete(key: 'auth_token');
  }

  bool get isLoggedIn => currentUser.value != null;

  Future<String?> getUserToken() async {
    try {
      firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        print('No user is currently signed in.');
        return null;
      }

      String? token = await firebaseUser.getIdToken();
      print(
          'Token retrieved for customer: ${token != null ? token.substring(0, 10) + '...' : 'null'}');
      return token;
    } catch (e) {
      print('Error getting customer token: $e');
      return null;
    }
  }

  // 수정된 부분: _updateUserToken 메서드 수정
  Future<void> _updateUserToken(firebase_auth.User firebaseUser) async {
    final tokenResult = await firebaseUser.getIdTokenResult();
    final token = tokenResult.token;
    if (token != null) {
      await _storage.write(key: 'auth_token', value: token);
      print('User token updated');
    } else {
      print('Failed to get user token');
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      if (userData['displayName'] != null) {
        await user.updateDisplayName(userData['displayName']);
      }
      if (userData['email'] != null) {
        await user.updateEmail(userData['email']);
      }
      if (userData['photoURL'] != null) {
        await user.updatePhotoURL(userData['photoURL']);
      }

      await user.reload();
      final updatedFirebaseUser = _firebaseAuth.currentUser;
      if (updatedFirebaseUser == null) return false;

      User updatedUser = User.fromFirebaseUser(updatedFirebaseUser);
      updatedUser = User(
        uid: updatedUser.uid,
        email: updatedUser.email,
        displayName: updatedUser.displayName,
        photoURL: updatedUser.photoURL,
        emailVerified: updatedUser.emailVerified,
        phoneNumber: updatedUser.phoneNumber,
        role: userData['role'] ?? updatedUser.role,
        meals: currentUser.value?.meals ?? [],
        visits: currentUser.value?.visits ?? [],
        likedRestaurants: currentUser.value?.likedRestaurants,
        coupons: currentUser.value?.coupons,
        createdAt: currentUser.value?.createdAt,
        updatedAt: DateTime.now(),
      );

      currentUser.value = updatedUser;
      await _updateUserToken(updatedFirebaseUser);

      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // 새로 추가된 getUserId 메서드
  Future<String?> getUserId() async {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser?.uid;
  }

  // Future<void> _updateUserToken(firebase_auth.User firebaseUser) async {
  //   final token = await firebaseUser.getIdToken();
  //   await _storage.write(key: 'auth_token', value: token);
  //   print('User token updated');
  // }
}
