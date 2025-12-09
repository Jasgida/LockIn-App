// lib/services/volume_stub.dart
class VolumeController {
  static VolumeController get instance => VolumeController();

  Future<double> getVolume() async => 0.5;
  void listener(Function(double) callback) {}
  void removeListener() {}
  void showSystemUI() {}
}