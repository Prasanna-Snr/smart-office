import 'package:flutter_test/flutter_test.dart';
import 'package:smart_office/services/firebase_service.dart';

void main() {
  group('Firebase Service Tests', () {
    test('Firebase service should have correct methods', () {
      // Test that the service has the required methods
      expect(FirebaseService.updateLedStatus, isA<Function>());
      expect(FirebaseService.getLedStatus, isA<Function>());
      expect(FirebaseService.ledStatusStream, isA<Function>());
    });
  });
}