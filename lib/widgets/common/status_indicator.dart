import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String onlineText;
  final String offlineText;
  final Color? onlineColor;
  final Color? offlineColor;
  final IconData? onlineIcon;
  final IconData? offlineIcon;

  const StatusIndicator({
    Key? key,
    required this.isOnline,
    this.onlineText = 'Online',
    this.offlineText = 'Offline',
    this.onlineColor = Colors.green,
    this.offlineColor = Colors.red,
    this.onlineIcon = Icons.cloud_done,
    this.offlineIcon = Icons.cloud_off,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isOnline ? onlineIcon : offlineIcon,
          color: isOnline ? onlineColor : offlineColor,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? onlineText : offlineText,
          style: TextStyle(
            color: isOnline ? onlineColor : offlineColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}