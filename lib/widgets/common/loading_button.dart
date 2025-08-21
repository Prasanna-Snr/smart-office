import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final String? loadingText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  const LoadingButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.loadingText,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon),
      label: Text(isLoading ? (loadingText ?? 'Loading...') : text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}