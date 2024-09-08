import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    // Get API Key from environment variables
    // if let mapsApiKey = ProcessInfo.processInfo.environment["API_KEY"] {
    //   GMSServices.provideAPIKey(mapsApiKey)
    // } else {
    //   print("Google Maps API key not found in environment variables.")
    // }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
