import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/info_card.dart';

class UserCountWidget extends StatelessWidget {
  final int userCount;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const UserCountWidget({
    Key? key,
    required this.userCount,
    required this.isLoading,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.people,
      title: 'Total Users',
      subtitle: isLoading 
          ? 'Loading...' 
          : '$userCount registered users',
      value: isLoading ? '...' : '$userCount',
      iconColor: AppTheme.primaryColor,
      onTap: onRefresh,
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              '$userCount',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
    );
  }
}