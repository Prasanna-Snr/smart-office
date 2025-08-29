import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_user.dart';
import 'email_service.dart';
import 'dart:math';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Store OTP temporarily (in production, use a more secure method)
  static final Map<String, String> _otpStorage = {};
  
  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Generate OTP
  static String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Sign up with email and password
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (!isValidEmail(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }
      
      // Check if email already exists
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          return {'success': false, 'message': 'Email already registered. Please sign in instead.'};
        }
      } catch (e) {
        // Continue if we can't check (might be network issue)
      }
      
      // Generate and store OTP
      final otp = _generateOTP();
      _otpStorage[email] = otp;
      
      // Send OTP email
      final emailSent = await EmailService.sendOTP(email, otp);
      if (!emailSent) {
        return {'success': false, 'message': 'Failed to send OTP email'};
      }
      
      return {
        'success': true, 
        'message': 'OTP sent to your email',
        'email': email,
        'password': password,
        'displayName': displayName,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Verify OTP and complete registration
  static Future<Map<String, dynamic>> verifyOTPAndRegister({
    required String email,
    required String otp,
    required String password,
    String? displayName,
  }) async {
    try {
      // Check if OTP matches
      if (_otpStorage[email] != otp) {
        return {'success': false, 'message': 'Invalid OTP. Please check and try again.'};
      }
      
      print('🔧 Attempting to create user account...');
      
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ User account created successfully');
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        print('✅ Display name updated');
      }
      
      // Try to store user data in Firestore (optional for now)
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': displayName,
          'isEmailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ User data stored in Firestore');
      } catch (firestoreError) {
        print('⚠️ Firestore error (continuing anyway): $firestoreError');
        // Continue even if Firestore fails
      }
      
      // Clean up OTP
      _otpStorage.remove(email);
      
      return {'success': true, 'message': 'Account created successfully'};
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      String message = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled. Please check Firebase Console.';
          break;
        case 'configuration-not-found':
          message = 'Firebase configuration error. Please check your setup.';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      print('❌ General registration error: $e');
      return {'success': false, 'message': 'Registration failed. Please try again.'};
    }
  }
  
  // Sign in with email and password
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (!isValidEmail(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return {'success': true, 'message': 'Signed in successfully'};
    } on FirebaseAuthException catch (e) {
      String message = 'Sign in failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password.';
          break;
        default:
          message = e.message ?? 'Sign in failed';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'message': 'Sign in failed. Please try again.'};
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get user data from Firestore
  static Future<AuthUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AuthUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (!isValidEmail(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }
      
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}