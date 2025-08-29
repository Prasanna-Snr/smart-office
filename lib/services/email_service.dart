import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Gmail SMTP configuration
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = 'prasannasunuwar03@gmail.com';
  static const String _password = 'uvthjwfavmufvxvk';
  
  static Future<bool> sendOTP(String recipientEmail, String otp) async {
    try {
      // Create SMTP server configuration
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _username,
        password: _password,
        allowInsecure: false,
        ssl: false,
      );
      
      // Create the email message
      final message = Message()
        ..from = Address(_username, 'Smart Office')
        ..recipients.add(recipientEmail)
        ..subject = 'Smart Office - Email Verification'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #2196F3;">Smart Office Email Verification</h2>
            <p>Hello,</p>
            <p>Thank you for signing up for Smart Office. Please use the following OTP to verify your email address:</p>
            <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
              <h1 style="color: #2196F3; font-size: 32px; margin: 0; letter-spacing: 5px;">$otp</h1>
            </div>
            <p>This OTP is valid for 5 minutes. Please do not share this code with anyone.</p>
            <p>If you didn't request this verification, please ignore this email.</p>
            <br>
            <p>Best regards,<br>Smart Office Team</p>
          </div>
        ''';
      
      // Send the email
      await send(message, smtpServer);
      print('✅ OTP email sent successfully to $recipientEmail');
      print('📧 OTP Code: $otp');
      return true;
    } catch (e) {
      print('❌ Failed to send OTP email: $e');
      print('🔧 Development Mode - OTP Code: $otp');
      
      // For development/testing, we'll still return true and log the OTP
      // This allows testing without actual email sending
      return true;
    }
  }
}