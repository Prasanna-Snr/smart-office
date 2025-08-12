import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Reference to the led_status in Firebase
  static DatabaseReference get ledStatusRef => _database.child('led_status');
  
  // Update LED status in Firebase
  static Future<void> updateLedStatus(bool status) async {
    try {
      await ledStatusRef.set(status);
      print('LED status updated to: $status');
    } catch (e) {
      print('Error updating LED status: $e');
      throw e;
    }
  }
  
  // Get current LED status from Firebase
  static Future<bool> getLedStatus() async {
    try {
      final snapshot = await ledStatusRef.get();
      if (snapshot.exists) {
        return snapshot.value as bool? ?? false;
      }
      return false;
    } catch (e) {
      print('Error getting LED status: $e');
      return false;
    }
  }
  
  // Listen to LED status changes in real-time
  static Stream<bool> ledStatusStream() {
    return ledStatusRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as bool? ?? false;
      }
      return false;
    });
  }
}