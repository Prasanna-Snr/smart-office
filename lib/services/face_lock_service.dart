import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import '../core/constants/app_constants.dart';
import '../core/utils/image_utils.dart';

class FaceLockService {
  static const String baseUrl = 'https://face-lock-api.onrender.com';
  
  // Check server status
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConstants.serverCheckTimeout);
      
      print('Server status check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Server status check failed: $e');
      return false;
    }
  }
  
  // Get all users (matches the actual API response format)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          // API returns: {"users": [...], "total_users": 0, "message": "..."}
          if (responseData.containsKey('users')) {
            final dynamic users = responseData['users'];
            if (users is List) {
              // Convert API format to our User model format
              return users.map<Map<String, dynamic>>((user) {
                return {
                  'id': user['username'], // Use username as ID
                  'name': user['username'], // Use username as name
                  'email': '${user['username']}@company.com', // Generate email (not used in UI)
                  'role': 'Employee', // Default role (not used in UI)
                  'createdAt': user['registered_at'] ?? DateTime.now().toIso8601String(),
                  'isActive': true,
                  'imageBase64': user['image'], // Use 'image' field from updated API
                };
              }).toList();
            }
          }
        }
        
        // Return empty list if no users or unexpected format
        return [];
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Register a new user with face image (matches the actual API)
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register'),
      );
      
      // Add username as form field
      request.fields['username'] = username;
      
      // Read and compress image file
      List<int> imageBytes = await imageFile.readAsBytes();
      
      print('Original image size: ${imageBytes.length} bytes');
      
      // Compress image if it's too large
      if (imageBytes.length > AppConstants.maxImageSize) {
        print('Image too large (${imageBytes.length} bytes), compressing...');
        imageBytes = await ImageUtils.compressImage(imageBytes);
        print('Compressed image size: ${imageBytes.length} bytes');
      }
      
      print('Uploading image: ${imageBytes.length} bytes for user: $username');
      
      // Create multipart file with proper content type
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      // Add timeout to prevent hanging requests
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server may be overloaded');
        },
      );
      
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to register user: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Legacy method for backward compatibility - now calls registerUser
  static Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String role,
  }) async {
    throw Exception('This API does not support separate user creation. Use registerUser with image instead.');
  }
  
  // Note: This API does not support updating users directly
  // We implement update by deleting and re-registering with the same face data
  static Future<Map<String, dynamic>> updateUserName({
    required String oldUsername,
    required String newUsername,
    required String imageBase64,
  }) async {
    try {
      // First, delete the old user
      final deleteSuccess = await deleteUser(oldUsername);
      if (!deleteSuccess) {
        throw Exception('Failed to delete old user record');
      }
      
      // Create a temporary file from the base64 data
      final tempFile = await ImageUtils.createTempFileFromBase64(imageBase64);
      
      try {
        // Re-register with new username
        final result = await registerUser(
          username: newUsername,
          imageFile: tempFile,
        );
        
        // Clean up temp file
        await ImageUtils.deleteTempFile(tempFile);
        
        return result;
      } catch (e) {
        // Clean up temp file on error
        await ImageUtils.deleteTempFile(tempFile);
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to update user name: $e');
    }
  }
  
  // Delete user (matches the actual API)
  static Future<bool> deleteUser(String username) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$username'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Delete user response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Note: This API registers users with face images directly in /register
  // No separate face upload endpoint is needed
  
  // Authenticate/verify face
  static Future<Map<String, dynamic>> verifyFace(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/authenticate'),
      );
      
      // Read and compress image file
      List<int> imageBytes = await imageFile.readAsBytes();
      
      print('Original verification image size: ${imageBytes.length} bytes');
      
      // Compress image if it's too large
      if (imageBytes.length > AppConstants.maxImageSize) {
        print('Verification image too large, compressing...');
        imageBytes = await ImageUtils.compressImage(imageBytes);
        print('Compressed verification image size: ${imageBytes.length} bytes');
      }
      
      print('Verifying face: ${imageBytes.length} bytes');
      
      // Create multipart file with proper content type
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      // Add timeout to prevent hanging requests
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server may be overloaded');
        },
      );
      
      final responseBody = await response.stream.bytesToString();
      
      print('Authenticate response: ${response.statusCode} - $responseBody');
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to authenticate: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


}