import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAWOcz09K8SYE0VQmYQSdblWSOCGXqP4Eo")
    // Get API Key from environment variables
    // if let mapsApiKey = ProcessInfo.processInfo.environment["API_KEY"] {
    //   GMSServices.provideAPIKey(mapsApiKey)
    // } else {
    //   print("Google Maps API key not found in environment variables.")
    // }
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
