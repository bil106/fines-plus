package com.finesplus

import android.net.Uri
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fines_plus/text_recognition")
            .setMethodCallHandler { call, result ->
                if (call.method != "recognizeLines") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                try {
                    val image = InputImage.fromFilePath(this, Uri.fromFile(java.io.File(call.arguments as String)))
                    recognizer.process(image)
                        .addOnSuccessListener { text ->
                            result.success(text.textBlocks.flatMap { block -> block.lines.map { it.text } })
                        }
                        .addOnFailureListener { result.error("recognition_failed", it.message, null) }
                        .addOnCompleteListener { recognizer.close() }
                } catch (e: Exception) {
                    recognizer.close()
                    result.error("recognition_failed", e.message, null)
                }
            }
    }
}
