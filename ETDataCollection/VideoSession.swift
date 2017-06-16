import AVFoundation
import CocoaLumberjack

class VideoSession {
    let captureDevice:AVCaptureDevice?
    let captureSession:AVCaptureSession?
    let recorder: Recorder?

    init(tempFilePath: URL) {
        self.captureDevice = DeviceUtil().getFrontCameraDevice()

        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration ()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        captureSession.commitConfiguration()
        self.captureSession = captureSession
        
        self.recorder = Recorder(
            captureSession: self.captureSession!,
            tempFilePath: tempFilePath)
    }
    
    open func getCaptureDevice() -> AVCaptureDevice? {
        return self.captureDevice
    }
    
    open func getCaptureSession() -> AVCaptureSession? {
        return self.captureSession
    }
    
    open func getRecorder() -> Recorder? {
        return self.recorder
    }
}
