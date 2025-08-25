import 'package:flutter/material.dart';
import 'dart:async';
import '../models/office_state.dart';
import '../services/firebase_service.dart';

class OfficeProvider extends ChangeNotifier {
  OfficeState _officeState = OfficeState();
  StreamSubscription<bool>? _ledStatusSubscription;
  StreamSubscription<bool>? _fanStatusSubscription;
  StreamSubscription<bool>? _doorStatusSubscription;
  StreamSubscription<double>? _temperatureSubscription;
  StreamSubscription<double>? _garbageLevelSubscription;
  StreamSubscription<bool>? _automaticModeSubscription;
  StreamSubscription<double>? _maxTempSubscription;
  
  bool _isAutomaticModeEnabled = false;
  double _automaticFanTemperature = 25.0;

  OfficeState get officeState => _officeState;

  bool get isDoorOpen => _officeState.isDoorOpen;
  bool get isLightOn => _officeState.isLightOn;
  bool get isFanOn => _officeState.isFanOn;
  bool get gasDetected => _officeState.gasDetected;
  int get totalUsers => _officeState.totalUsers;
  double get roomTemperature => _officeState.roomTemperature;
  double get garbageLevel => _officeState.garbageLevel;
  bool get isAutomaticModeEnabled => _isAutomaticModeEnabled;
  double get automaticFanTemperature => _automaticFanTemperature;

  OfficeProvider() {
    _initializeFirebaseListeners();
    _loadInitialData();
  }

  // Initialize Firebase listeners for LED status, fan status, and temperature
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

    // Fan status listener
    _fanStatusSubscription = FirebaseService.fanStatusStream().listen(
      (bool status) {
        if (_officeState.isFanOn != status) {
          _officeState.isFanOn = status;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to fan status: $error');
      },
    );

    // Door status listener
    _doorStatusSubscription = FirebaseService.doorStatusStream().listen(
      (bool isOpen) {
        if (_officeState.isDoorOpen != isOpen) {
          _officeState.isDoorOpen = isOpen;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to door status: $error');
      },
    );

    // Temperature listener
    _temperatureSubscription = FirebaseService.temperatureStream().listen(
      (double temperature) {
        if (_officeState.roomTemperature != temperature) {
          _officeState.roomTemperature = temperature;
          _checkAutomaticFanControl(temperature);
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

    // Automatic mode listener
    _automaticModeSubscription = FirebaseService.automaticModeStream().listen(
      (bool enabled) {
        if (_isAutomaticModeEnabled != enabled) {
          _isAutomaticModeEnabled = enabled;
          // Check fan control when automatic mode changes
          _checkAutomaticFanControl(_officeState.roomTemperature);
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to automatic mode: $error');
      },
    );

    // Max temperature listener
    _maxTempSubscription = FirebaseService.maxTempStream().listen(
      (double maxTemp) {
        if (_automaticFanTemperature != maxTemp) {
          _automaticFanTemperature = maxTemp;
          // Check fan control when max temperature changes
          _checkAutomaticFanControl(_officeState.roomTemperature);
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error listening to max temperature: $error');
      },
    );
  }

  // Load initial data from Firebase
  Future<void> _loadInitialData() async {
    try {
      // Load LED status
      final ledStatus = await FirebaseService.getLedStatus();
      _officeState.isLightOn = ledStatus;

      // Load fan status
      final fanStatus = await FirebaseService.getFanStatus();
      _officeState.isFanOn = fanStatus;

      // Load door status
      final doorStatus = await FirebaseService.getDoorStatus();
      _officeState.isDoorOpen = doorStatus;

      // Load temperature
      final temperature = await FirebaseService.getTemperature();
      _officeState.roomTemperature = temperature;

      // Load garbage level
      final garbageLevel = await FirebaseService.getGarbageLevel();
      _officeState.garbageLevel = garbageLevel;

      // Load automatic mode
      final automaticMode = await FirebaseService.getAutomaticMode();
      _isAutomaticModeEnabled = automaticMode;

      // Load max temperature
      final maxTemp = await FirebaseService.getMaxTemp();
      _automaticFanTemperature = maxTemp;

      // Check automatic fan control after loading all data
      _checkAutomaticFanControl(_officeState.roomTemperature);

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

  Future<void> toggleFan() async {
    try {
      final newStatus = !_officeState.isFanOn;
      // Update Firebase first
      await FirebaseService.updateFanStatus(newStatus);

      // Update local state (this will also be updated by the Firebase listener)
      _officeState.isFanOn = newStatus;

      notifyListeners();
    } catch (e) {
      print('Error toggling fan: $e');
      // Show error to user or handle gracefully
    }
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

  Future<void> toggleAutomaticMode() async {
    try {
      final newMode = !_isAutomaticModeEnabled;
      await FirebaseService.updateAutomaticMode(newMode);
      _isAutomaticModeEnabled = newMode;
      // Check fan control immediately after toggling automatic mode
      _checkAutomaticFanControl(_officeState.roomTemperature);
      notifyListeners();
    } catch (e) {
      print('Error toggling automatic mode: $e');
      throw e;
    }
  }

  Future<void> setAutomaticFanTemperature(double temperature) async {
    try {
      await FirebaseService.updateMaxTemp(temperature);
      _automaticFanTemperature = temperature;
      // Check fan control immediately after setting new temperature
      _checkAutomaticFanControl(_officeState.roomTemperature);
      notifyListeners();
    } catch (e) {
      print('Error setting automatic fan temperature: $e');
      throw e;
    }
  }

  void _checkAutomaticFanControl(double temperature) {
    if (_isAutomaticModeEnabled) {
      final shouldTurnOnFan = temperature > _automaticFanTemperature;
      print('Automatic fan control check: temp=$temperature, maxTemp=$_automaticFanTemperature, shouldTurnOn=$shouldTurnOnFan, currentFanStatus=${_officeState.isFanOn}');
      
      if (shouldTurnOnFan != _officeState.isFanOn) {
        // Only update if the fan state needs to change
        print('Fan state needs to change from ${_officeState.isFanOn} to $shouldTurnOnFan');
        toggleFan();
      }
    }
  }



  @override
  void dispose() {
    _ledStatusSubscription?.cancel();
    _fanStatusSubscription?.cancel();
    _doorStatusSubscription?.cancel();
    _temperatureSubscription?.cancel();
    _garbageLevelSubscription?.cancel();
    _automaticModeSubscription?.cancel();
    _maxTempSubscription?.cancel();
    super.dispose();
  }
}