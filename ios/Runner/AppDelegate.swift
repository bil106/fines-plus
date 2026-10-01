import Flutter
import GoogleMaps
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String, !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TextRecognition") {
      let channel = FlutterMethodChannel(name: "fines_plus/text_recognition", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        guard call.method == "recognizeLines",
              let path = call.arguments as? String,
              let image = UIImage(contentsOfFile: path),
              let cgImage = image.cgImage else {
          result(FlutterMethodNotImplemented)
          return
        }
        DispatchQueue.global(qos: .userInitiated).async {
          let request = VNRecognizeTextRequest()
          request.recognitionLevel = .accurate
          request.usesLanguageCorrection = false
          let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up
          do {
            try VNImageRequestHandler(cgImage: cgImage, orientation: orientation).perform([request])
            let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
            DispatchQueue.main.async { result(lines) }
          } catch {
            DispatchQueue.main.async { result(FlutterError(code: "recognition_failed", message: error.localizedDescription, details: nil)) }
          }
        }
      }
    }
  }
}
