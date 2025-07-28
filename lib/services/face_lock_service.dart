import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

class FaceLockService {
  static const String baseUrl = 'https://face-lock-api.onrender.com';
  
  // Check if the API server is available
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Server status check failed: $e');
      return false;
    }
  }
  
  
  // Get all users (matches the actual API response format)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('Fetching users from: $baseUrl/users');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout after 15 seconds');
        },
      );
      
      print('Get users response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          // API returns: {"users": [...], "total_users": 0, "message": "..."}
          if (responseData.containsKey('users')) {
            final dynamic users = responseData['users'];
            if (users is List) {
              // Convert API format to our User model format
              return users.map<Map<String, dynamic>>((user) {
                print('Raw user data from API: $user');
                print('Image field: ${user['image']}');
                print('Image type: ${user['image'].runtimeType}');
                print('Image length: ${user['image']?.toString().length ?? 0}');
                
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
      } else if (response.statusCode == 502) {
        throw Exception('Face Lock API server is currently unavailable (502). Please try again later.');
      } else {
        throw Exception('Failed to load users: HTTP ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('502')) {
        throw Exception('Face Lock API server is currently unavailable. Please try again later.');
      } else {
        throw Exception('Network error: $e');
      }
    }
  }
  
  // Register a new user with face image (matches the actual API)
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required File imageFile,
  }) async {
    int maxRetries = 3;
    int retryDelay = 2; // seconds
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('Registration attempt $attempt/$maxRetries for user: $username');
        
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/register'),
        );
        
        // Add username as form field
        request.fields['username'] = username;
        
        // Read image file as bytes
        List<int> imageBytes = await imageFile.readAsBytes();
        
        // Create multipart file with proper content type
        var multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
          contentType: http_parser.MediaType('image', 'jpeg'),
        );
        
        request.files.add(multipartFile);
        
        print('Sending request with:');
        print('- Username: $username');
        print('- Image path: ${imageFile.path}');
        print('- Image exists: ${await imageFile.exists()}');
        print('- Image size: ${imageBytes.length} bytes');
        print('- API URL: $baseUrl/register');
        
        // Set timeout
        final response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout after 30 seconds');
          },
        );
        
        final responseBody = await response.stream.bytesToString();
        
        print('Register response: ${response.statusCode} - $responseBody');
        
        if (response.statusCode == 200) {
          final responseJson = json.decode(responseBody);
          print('Parsed register response: $responseJson');
          return responseJson;
        } else if (response.statusCode == 502 && attempt < maxRetries) {
          print('Server error (502), retrying in $retryDelay seconds...');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2; // Exponential backoff
          continue;
        } else {
          String errorMessage = 'HTTP ${response.statusCode}';
          if (response.statusCode == 502) {
            errorMessage = 'Server temporarily unavailable (502). The Face Lock API server may be down or overloaded.';
          } else if (response.statusCode == 400) {
            errorMessage = 'Bad request (400). Please check the image format and username.';
          } else if (response.statusCode == 409) {
            errorMessage = 'User already exists (409). Please choose a different username.';
          }
          throw Exception('$errorMessage\nResponse: $responseBody');
        }
      } catch (e) {
        if (attempt == maxRetries) {
          if (e.toString().contains('502')) {
            throw Exception('Face Lock API server is currently unavailable. Please try again later.');
          } else {
            throw Exception('Network error after $maxRetries attempts: $e');
          }
        } else {
          print('Attempt $attempt failed: $e');
          await Future.delayed(Duration(seconds: retryDelay));
          retryDelay *= 2;
        }
      }
    }
    
    throw Exception('Failed to register user after $maxRetries attempts');
  }

  // Legacy method for backward compatibility - now calls registerUser
  static Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String role,
  }) async {
    throw Exception('This API does not support separate user creation. Use registerUser with image instead.');
  }
  
  // Note: This API does not support updating users
  // Users must be deleted and re-registered to change information
  
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
      
      // Read image file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();
      
      // Create multipart file with proper content type
      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
        contentType: http_parser.MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
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