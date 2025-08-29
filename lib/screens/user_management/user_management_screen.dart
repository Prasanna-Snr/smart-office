import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../services/face_lock_service.dart';
import '../../widgets/common/status_indicator.dart';
import '../../widgets/user_management/user_list_item.dart';
import '../../core/constants/app_constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  bool _isServerOnline = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkServerAndLoadUsers();
  }

  Future<void> _checkServerAndLoadUsers() async {
    final serverStatus = await FaceLockService.checkServerStatus();
    setState(() => _isServerOnline = serverStatus);

    if (serverStatus) {
      _loadUsers();
    } else {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Server is currently offline. Please try again later.');
    }
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);

      final apiUsers = await FaceLockService.getAllUsers();

      setState(() {
        _users = apiUsers.map((userData) => User.fromJson(userData)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: StatusIndicator(isOnline: _isServerOnline),
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
            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 16),

            // Users List
            Expanded(
              child: _buildUsersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isServerOnline ? _showAddUserDialog : null,
            icon: const Icon(Icons.camera_alt),
            label: Text(_isServerOnline ? 'Take Photo & Add User' : 'Server Offline'),
            style: FilledButton.styleFrom(
              backgroundColor: _isServerOnline ? AppTheme.primaryColor : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isServerOnline ? _verifyFace : null,
            icon: const Icon(Icons.face),
            label: Text(_isServerOnline ? 'Verify Face' : 'Server Offline'),
            style: FilledButton.styleFrom(
              backgroundColor: _isServerOnline ? AppTheme.successColor : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return UserListItem(
            user: user,
            onEdit: () => _showEditUserDialog(user),
            onDelete: () => _deleteUser(user.id),
          );
        },
      ),
    );
  }

  Future<void> _showAddUserDialog() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
        maxWidth: AppConstants.maxImageDimension,
        maxHeight: AppConstants.maxImageDimension,
      );

      if (image != null) {
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Photo captured! Now enter the name:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
              textCapitalization: TextCapitalization.words,
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

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'New Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
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
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != user.name) {
                Navigator.pop(context);
                _updateUserName(user, newName);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUserWithPhoto(String name, File imageFile) async {
    _showLoadingDialog('Registering user...');

    try {
      await FaceLockService.registerUser(
        username: name,
        imageFile: imageFile,
      );

      _closeLoadingDialog();
      _showSuccessSnackBar('User "$name" registered successfully!');
      await _loadUsers();
    } catch (e) {
      _closeLoadingDialog();
      _showErrorSnackBar('Failed to register user: $e');
    }
  }

  Future<void> _updateUserName(User user, String newName) async {
    if (user.imageBase64 == null || user.imageBase64!.isEmpty) {
      _showErrorSnackBar('Cannot update user without face data.');
      return;
    }

    _showLoadingDialog('Updating user name...');

    try {
      await FaceLockService.updateUserName(
        oldUsername: user.name,
        newUsername: newName,
        imageBase64: user.imageBase64!,
      );

      _closeLoadingDialog();
      _showSuccessSnackBar('User name updated successfully!');
      await _loadUsers();
    } catch (e) {
      _closeLoadingDialog();
      _showErrorSnackBar('Failed to update user name: $e');
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FaceLockService.deleteUser(userId);
        _showSuccessSnackBar('User deleted successfully!');
        await _loadUsers();
      } catch (e) {
        _showErrorSnackBar('Failed to delete user: $e');
      }
    }
  }

  Future<void> _verifyFace() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
        maxWidth: AppConstants.maxImageDimension,
        maxHeight: AppConstants.maxImageDimension,
      );

      if (image != null) {
        _showLoadingDialog('Verifying face...');

        final result = await FaceLockService.verifyFace(File(image.path));

        _closeLoadingDialog();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verification Result'),
            content: Text(result.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _closeLoadingDialog();
      _showErrorSnackBar('Face verification failed: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _closeLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
}