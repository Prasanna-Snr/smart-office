class OfficeState {
  bool isDoorOpen;
  bool isLightOn;
  bool isFanOn;
  bool gasDetected;
  int totalUsers;
  double roomTemperature; // in Celsius

  OfficeState({
    this.isDoorOpen = false,
    this.isLightOn = false,
    this.isFanOn = false,
    this.gasDetected = false,
    this.totalUsers = 5,
    this.roomTemperature = 22.5,
  });
}