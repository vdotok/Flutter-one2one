import UIKit
import Flutter

import ReplayKit
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


// MARK:- Key-Value Observer callback

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("testing ......\(keyPath)")
        
           //    pickerView.preferredExtension = "com.norgic.vdotok.sharescreen"

//        if keyPath == "captured" {
//
//            if !UIScreen.main.isCaptured {
//
//guard isScreenSharingActive, currentSession!.isBroadCaster else {
//
//                    return
//
//                }
//
//if TogeeUser.shared.isRecordingScreen{
//
//                    NotificationCenter.default.post(name: .forceEndScreenRecording, object: nil)
//
//                }
//
//UIApplication.shared.isIdleTimerDisabled = false
//
//                self.endScreenSharing()
//
//            }
//
//        }
//
//    }


}
}
