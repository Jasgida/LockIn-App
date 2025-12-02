// lib/services/pin_overlay_stub.dart
// Used only on Web/Chrome/Windows so the app compiles
class PinOverlayService {
  PinOverlayService._();
  factory PinOverlayService() => PinOverlayService._();

  Future<void> start() async {}
  void stop() {}
}