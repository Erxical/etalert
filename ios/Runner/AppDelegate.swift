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
    NSString* mapsApiKey = [NSProcessInfo processInfo] environment[@"API_KEY"];
    [GMSServices.provideAPIKey:mapsApiKey];
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
