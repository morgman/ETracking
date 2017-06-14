import AVFoundation
import CocoaLumberjack

struct AlertUtil {
    func getPermissionDeniedAlert() -> UIAlertController? {
        let videoFailedAlert = UIAlertController(title: "Permission Denied", message: "User denied access to record video comment.", preferredStyle: UIAlertControllerStyle.alert)
        videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            DDLogWarn("Placeholder")
        }))
        
        return videoFailedAlert
    }
    
    func getRecordingCompleteAlert(tempFilePath: URL) -> UIAlertController? {
        let videoFailedAlert = UIAlertController(title: "Recording complete", message: "View recording at \(tempFilePath)", preferredStyle: UIAlertControllerStyle.alert)
        videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            DDLogWarn("Placeholder")
        }))
        
        return videoFailedAlert
    }
    
    func getPermissionGrantedAlert(handler: ((UIAlertAction) -> Swift.Void)?) -> UIAlertController? {
        DDLogInfo("Display Alert indicating Test should start")
        
        let videoFailedAlert = UIAlertController(
            title: "Permission Granted",
            message: "Start Testing Now...",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        videoFailedAlert.addAction(UIAlertAction(
            title: "Ok",
            style: .default,
            handler: handler
        ))
        
        return videoFailedAlert
    }
}
