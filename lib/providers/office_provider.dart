import 'package:flutter/material.dart';
import 'dart:async';
import '../models/office_state.dart';
import '../services/firebase_service.dart';

class OfficeProvider extends ChangeNotifier {
  OfficeState _officeState = OfficeState();
  StreamSubscription<bool>? _ledStatusSubscription;
  StreamSubscription<double>? _temperatureSubscription;
  StreamSubscription<double>? _garbageLevelSubscription;

  OfficeState get officeState => _officeState;

  bool get isDoorOpen => _officeState.isDoorOpen;
  bool get isLightOn => _officeState.isLightOn;
  bool get isFanOn => _officeState.isFanOn;
  bool get gasDetected => _officeState.gasDetected;
  int get totalUsers => _officeState.totalUsers;
  double get roomTemperature => _officeState.roomTemperature;
  double get garbageLevel => _officeState.garbageLevel;

  OfficeProvider() {
    _initializeFirebaseListeners();
    _loadInitialData();
  }

  // Initialize Firebase listeners for LED status and temperature
  void _initializeFirebaseListeners() {
    // LED status listener
    _ledStatusSubscription = FirebaseService.ledStatusStream().listen(
      (bool status) {
        if (_officeState.isLightOn != status) {
          _officeState.isLightOn = status;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to LED status: $error');
      },
    );

    // Temperature listener
    _temperatureSubscription = FirebaseService.temperatureStream().listen(
      (double temperature) {
        if (_officeState.roomTemperature != temperature) {
          _officeState.roomTemperature = temperature;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to temperature: $error');
      },
    );

    // Garbage level listener
    _garbageLevelSubscription = FirebaseService.garbageLevelStream().listen(
      (double garbageLevel) {
        if (_officeState.garbageLevel != garbageLevel) {
          _officeState.garbageLevel = garbageLevel;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to garbage level: $error');
      },
    );
  }

  // Load initial data from Firebase
  Future<void> _loadInitialData() async {
    try {
      // Load LED status
      final status = await FirebaseService.getLedStatus();
      _officeState.isLightOn = status;

      // Load temperature
      final temperature = await FirebaseService.getTemperature();
      _officeState.roomTemperature = temperature;

      // Load garbage level
      final garbageLevel = await FirebaseService.getGarbageLevel();
      _officeState.garbageLevel = garbageLevel;

      notifyListeners();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  void toggleDoor() {
    _officeState.isDoorOpen = !_officeState.isDoorOpen;
    notifyListeners();
  }

  void openDoorWithFaceRecognition() {
    if (!_officeState.isDoorOpen) {
      _officeState.isDoorOpen = true;
      notifyListeners();
    }
  }

  Future<void> toggleLight() async {
    try {
      final newStatus = !_officeState.isLightOn;
      // Update Firebase first
      await FirebaseService.updateLedStatus(newStatus);

      // Update local state (this will also be updated by the Firebase listener)
      _officeState.isLightOn = newStatus;

      notifyListeners();
    } catch (e) {
      print('Error toggling light: $e');
      // Show error to user or handle gracefully
    }
  }

  void toggleFan() {
    _officeState.isFanOn = !_officeState.isFanOn;
    notifyListeners();
  }

  void simulateGasDetection() {
    _officeState.gasDetected = !_officeState.gasDetected;
    notifyListeners();
  }

  void dismissGasAlert() {
    _officeState.gasDetected = false;
    notifyListeners();
  }

  void updateTotalUsers(int users) {
    _officeState.totalUsers = users;
    notifyListeners();
  }

  void updateRoomTemperature(double temperature) {
    _officeState.roomTemperature = temperature;
    notifyListeners();
  }

  Future<void> updateGarbageLevel(double level) async {
    try {
      final clampedLevel = level.clamp(0.0, 100.0);
      await FirebaseService.updateGarbageLevel(clampedLevel);
      _officeState.garbageLevel = clampedLevel;
      notifyListeners();
    } catch (e) {
      print('Error updating garbage level: $e');
      throw e;
    }
  }



  @override
  void dispose() {
    _ledStatusSubscription?.cancel();
    _temperatureSubscription?.cancel();
    _garbageLevelSubscription?.cancel();
    super.dispose();
  }
}