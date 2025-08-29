import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_button.dart';
import '../../theme/app_theme.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final String displayName;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  Timer? _timer;
  int _remainingTime = 300; // 5 minutes in seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Clear any previous errors when entering OTP screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError(); // Clear any previous errors
    
    final success = await authProvider.verifyOTPAndRegister(
      email: widget.email,
      otp: otp,
      password: widget.password,
      displayName: widget.displayName,
    );

    if (success && mounted) {
      // Clear any errors before navigation - successful verification
      authProvider.clearError();
      
      // Show brief success feedback and navigate immediately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 1500),
        ),
      );
      
      // AuthWrapper will automatically detect the auth state change and navigate to HomeScreen
      // The navigation happens automatically via Firebase Auth state changes
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final result = await authProvider.signUp(
      email: widget.email,
      password: widget.password,
      displayName: widget.displayName,
    );

    if (result['success'] && mounted) {
      setState(() {
        _remainingTime = 300;
        _canResend = false;
      });
      _startTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent again!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all digits are entered
    if (_otpCode.length == 6) {
      // Add a small delay to ensure UI is updated before verification
      Future.delayed(const Duration(milliseconds: 100), () {
        _verifyOTP();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'We\'ve sent a 6-digit verification code to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onOTPChanged(value, index),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Timer
              if (!_canResend)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resend code in $_formattedTime',
                        style: TextStyle(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Error Message
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.errorMessage != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return LoadingButton(
                    onPressed: _verifyOTP,
                    isLoading: authProvider.isLoading,
                    child: const Text('Verify & Create Account'),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Resend Button
              TextButton.icon(
                onPressed: _canResend ? _resendOTP : null,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _canResend ? 'Resend Code' : 'Resend Available Soon',
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Back to Sign In
              TextButton(
                onPressed: () {
                  // Clear errors before going back
                  Provider.of<AuthProvider>(context, listen: false).clearError();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Back to Sign In',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}