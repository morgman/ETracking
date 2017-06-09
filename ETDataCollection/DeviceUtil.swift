import AVFoundation
import CocoaLumberjack

struct DeviceUtil {
    func getFrontCameraDevice() -> AVCaptureDevice? {
        if let deviceSession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front) {
            if let devices:[AVCaptureDevice] = deviceSession.devices {
                //            if let devices:[AVCaptureDevice] = AVCaptureDevice.devices() as? [AVCaptureDevice] {
                for device in devices {
                    if (device.hasMediaType(AVMediaTypeVideo)) {
                        
                        if(device.position == AVCaptureDevicePosition.front) {
                            if(device.isFocusModeSupported(AVCaptureFocusMode.continuousAutoFocus)) {
                                do {
                                    try device.lockForConfiguration()
                                    device.focusMode = AVCaptureFocusMode.continuousAutoFocus
                                    device.unlockForConfiguration()
                                } catch let error as NSError {
                                    DDLogError("Error attempting to lock device for configuration: '\(error.localizedDescription)'")
                                }
                            }
                            
                            return device
                        }
                    }
                }
            }
        }

        return nil
    }
}
