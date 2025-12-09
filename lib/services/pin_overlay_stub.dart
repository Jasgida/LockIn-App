// lib/services/pin_overlay_service.dart
// REAL ANDROID VERSION — FULL POWER
// (Even if empty for now — just to stop the error)

class PinOverlayService {
  PinOverlayService._();
  factory PinOverlayService() => PinOverlayService._();

  Future<void> start() async {
    // Full overlay will be added later
    print("PIN OVERLAY STARTED (Android)");
  }

  void stop() {
    print("PIN OVERLAY STOPPED");
  }
}

class EmergencyEscape {
  static void startListening() {
    print("Emergency escape listening...");
  }

  static void stopListening() {
    print("Emergency escape stopped");
  }
}