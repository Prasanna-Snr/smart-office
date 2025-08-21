import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = user.imageBase64 != null && user.imageBase64!.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: hasImage ? AppTheme.successColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildUserImage(),
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
                        hasImage ? Icons.verified_user : Icons.person_outline,
                        size: 14,
                        color: hasImage ? AppTheme.successColor : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasImage ? 'Face registered' : 'No face data',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasImage ? AppTheme.successColor : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    color: AppTheme.primaryColor,
                  ),
                  tooltip: 'Edit Name',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserImage() {
    if (user.imageBase64 != null && user.imageBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(user.imageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}