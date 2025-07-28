import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/face_lock_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  bool isLoading = true;
  bool isServerOnline = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkServerAndLoadUsers();
  }

  Future<void> _checkServerAndLoadUsers() async {
    // Check server status first
    final serverStatus = await FaceLockService.checkServerStatus();
    setState(() {
      isServerOnline = serverStatus;
    });
    
    if (serverStatus) {
      _loadUsers();
    } else {
      setState(() => isLoading = false);
      _showErrorSnackBar('Server is currently offline. Please try again later.');
    }
  }



  Future<void> _loadUsers() async {
    try {
      setState(() => isLoading = true);
      
      final apiUsers = await FaceLockService.getAllUsers();
      print('Loaded ${apiUsers.length} users from API');
      
      setState(() {
        users = apiUsers.map((userData) {
          final user = User.fromJson(userData);
          print('User: ${user.name}, Has image: ${user.imageBase64 != null && user.imageBase64!.isNotEmpty}');
          return user;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          // Server status indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isServerOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: isServerOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isServerOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isServerOnline ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _checkServerAndLoadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add User Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isServerOnline ? () => _showAddUserDialog() : null,
                icon: const Icon(Icons.camera_alt),
                label: Text(isServerOnline ? 'Take Photo & Add User' : 'Server Offline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isServerOnline ? AppTheme.primaryColor : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Face Verification Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isServerOnline ? _verifyFace : null,
                icon: const Icon(Icons.face),
                label: Text(isServerOnline ? 'Verify Face' : 'Server Offline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isServerOnline ? AppTheme.successColor : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Users List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found.\nTap "Add New User" to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // User Image
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: user.imageBase64 != null && user.imageBase64!.isNotEmpty 
                                                ? AppTheme.successColor 
                                                : Colors.grey, 
                                            width: 2
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: _buildUserImage(user),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // User Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  user.imageBase64 != null && user.imageBase64!.isNotEmpty 
                                                      ? Icons.verified_user 
                                                      : Icons.person_outline,
                                                  size: 14,
                                                  color: user.imageBase64 != null && user.imageBase64!.isNotEmpty 
                                                      ? AppTheme.successColor 
                                                      : Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  user.imageBase64 != null && user.imageBase64!.isNotEmpty 
                                                      ? 'Face registered' 
                                                      : 'No face data',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: user.imageBase64 != null && user.imageBase64!.isNotEmpty 
                                                        ? AppTheme.successColor 
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Delete Button
                                      IconButton(
                                        onPressed: () => _deleteUser(user.id),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Delete User',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddUserDialog() async {
    // First, take a photo
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduced from 80 to 50 to minimize file size
        maxWidth: 800,    // Limit image dimensions
        maxHeight: 800,   // Limit image dimensions
      );
      
      if (image != null) {
        // Photo taken successfully, now ask for name only
        _showNameInputDialog(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to access camera: $e');
    }
  }

  void _showNameInputDialog(File imageFile) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show captured image preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Photo captured! Now enter the name:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _addUserWithPhoto(nameController.text.trim(), imageFile);
              } else {
                _showErrorSnackBar('Please enter a name');
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }



  Future<void> _addUserWithPhoto(String name, File imageFile) async {
    _showLoadingDialog('Registering user with face...');
    
    try {
      // Register user with face image using the correct API
      final userResponse = await FaceLockService.registerUser(
        username: name,
        imageFile: imageFile,
      );
      
      _closeLoadingDialog();
      _showSuccessSnackBar('User "$name" registered successfully with face recognition!');
      await _loadUsers(); // Refresh the list
    } catch (e) {
      _closeLoadingDialog();
      
      String errorMessage = e.toString();
      
      // Check for specific error types
      if (errorMessage.contains('Face already registered for user:')) {
        _showDuplicateFaceDialog(errorMessage, name);
      } else if (errorMessage.contains('Request timeout') || errorMessage.contains('502')) {
        _showServerErrorDialog(name, imageFile);
      } else if (errorMessage.contains('Network error') || errorMessage.contains('SocketException')) {
        _showNetworkErrorDialog(name, imageFile);
      } else {
        _showErrorSnackBar('Failed to register user: $errorMessage');
      }
    }
  }

  void _showServerErrorDialog(String name, File imageFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Server Issue',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The server is currently overloaded or experiencing issues.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'This can happen when:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• The server is processing other requests'),
            Text('• The image file is too large'),
            Text('• The server needs time to restart'),
            SizedBox(height: 12),
            Text(
              'Please wait a moment and try again.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                _addUserWithPhoto(name, imageFile);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showNetworkErrorDialog(String name, File imageFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Network Error',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to connect to the server.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Please check:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Your internet connection'),
            Text('• Server availability'),
            Text('• Try again in a few moments'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addUserWithPhoto(name, imageFile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateFaceDialog(String errorMessage, String attemptedName) {
    // Extract existing username and similarity from error message
    String existingUser = 'Unknown';
    String similarity = '70%';
    
    // Parse the error message to get details
    if (errorMessage.contains('Face already registered for user:')) {
      try {
        // Extract existing username
        int userStart = errorMessage.indexOf('Face already registered for user:') + 33;
        int userEnd = errorMessage.indexOf('.', userStart);
        if (userEnd > userStart) {
          existingUser = errorMessage.substring(userStart, userEnd).trim();
        }
        
        // Extract similarity percentage
        if (errorMessage.contains('Similarity:')) {
          int simStart = errorMessage.indexOf('Similarity:') + 11;
          int simEnd = errorMessage.indexOf('%', simStart) + 1;
          if (simEnd > simStart) {
            similarity = errorMessage.substring(simStart, simEnd).trim();
          }
        }
      } catch (e) {
        print('Error parsing duplicate face message: $e');
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Already Registered',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This face is already registered!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Text('Existing User: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Flexible(
                        child: Text(
                          existingUser, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.analytics, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Text('Face Match: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Flexible(
                        child: Text(
                          similarity, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Each person can only register once. Please use a different person or contact the administrator.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  Future<void> _deleteUser(String id) async {
    // Find the user name for the confirmation dialog
    final user = users.firstWhere((u) => u.id == id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              
              // Show loading dialog
              _showLoadingDialog('Deleting user...');
              
              try {
                final success = await FaceLockService.deleteUser(id);
                _closeLoadingDialog();
                
                if (success) {
                  _showSuccessSnackBar('User "${user.name}" deleted successfully!');
                  // Refresh the list to update UI
                  await _loadUsers();
                } else {
                  _showErrorSnackBar('Failed to delete user');
                }
              } catch (e) {
                _closeLoadingDialog();
                _showErrorSnackBar('Failed to delete user: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  Future<void> _verifyFace() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduced quality to minimize file size
        maxWidth: 800,    // Limit image dimensions
        maxHeight: 800,   // Limit image dimensions
      );
      
      if (image != null) {
        _showLoadingDialog('Authenticating face...');
        
        try {
          final result = await FaceLockService.verifyFace(File(image.path));
          _closeLoadingDialog();
          
          if (result['authenticated'] == true) {
            _showSuccessDialog(
              'Authentication Successful!', 
              'Welcome ${result['username']}!\nAccuracy: ${result['accuracy']}%'
            );
          } else {
            _showErrorDialog(
              'Authentication Failed', 
              'Face not recognized.\nBest match: ${result['best_match'] ?? 'None'}\nAccuracy: ${result['accuracy']}%'
            );
          }
        } catch (e) {
          _closeLoadingDialog();
          _showErrorDialog('Authentication Error', 'Failed to authenticate: $e');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to access camera: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button from closing
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  void _closeLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildUserImage(User user) {
    print('Building image for user: ${user.name}');
    print('ImageBase64 is null: ${user.imageBase64 == null}');
    print('ImageBase64 is empty: ${user.imageBase64?.isEmpty ?? true}');
    print('ImageBase64 length: ${user.imageBase64?.length ?? 0}');
    
    if (user.imageBase64 != null && user.imageBase64!.isNotEmpty) {
      try {
        // Check if it's a valid base64 string
        String base64String = user.imageBase64!;
        
        // Remove data URL prefix if present (data:image/jpeg;base64,)
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        
        print('Cleaned base64 string length: ${base64String.length}');
        print('First 50 chars: ${base64String.substring(0, base64String.length > 50 ? 50 : base64String.length)}');
        
        // Decode base64 image
        Uint8List imageBytes = base64Decode(base64String);
        print('Successfully decoded ${imageBytes.length} bytes');
        
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image for ${user.name}: $error');
            return _buildDefaultAvatar(user);
          },
        );
      } catch (e) {
        print('Error decoding base64 image for ${user.name}: $e');
        return _buildDefaultAvatar(user);
      }
    } else {
      print('No image data for user: ${user.name}');
      // Show a placeholder indicating no image instead of initials
      return _buildNoImagePlaceholder(user);
    }
  }

  Widget _buildDefaultAvatar(User user) {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              'Error',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder(User user) {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              color: Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              'No Photo',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),  
        ],
      ),
    );
  }


}