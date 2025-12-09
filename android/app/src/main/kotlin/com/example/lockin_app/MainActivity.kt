package com.example.lockin_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.BatteryManager
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val CHANNEL = "lockin_boot_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startPinService") {
                startPinServiceFromBoot(this)
                result.success("started")
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        fun startPinServiceFromBoot(context: Context) {
            // This runs in background — triggers Dart code via platform channel
            val engine = FlutterEngine(context)
            engine.dartExecutor.executeDartEntrypoint(
                io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint.createDefault()
            )
            MethodChannel(engine.dartExecutor.binaryMessenger, "lockin_boot_channel")
                .invokeMethod("startPinService", null)
            // Don't destroy engine — it will clean up automatically
        }
    }
}