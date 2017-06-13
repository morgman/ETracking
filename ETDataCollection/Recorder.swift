import CocoaLumberjack
import AVFoundation

class Recorder : NSObject {
    var movieOutput:AVCaptureMovieFileOutput?
    var captureSession:AVCaptureSession?
    var tempFilePath: URL?
    
    init(captureSession: AVCaptureSession, tempFilePath: URL) {
        self.tempFilePath = tempFilePath
        self.captureSession = captureSession
        self.movieOutput = AVCaptureMovieFileOutput()

        self.captureSession?.addOutput(self.movieOutput)
    }
    
    open func startRecording() {
        if let _ = self.captureSession {
            movieOutput?.startRecording(toOutputFileURL: self.tempFilePath, recordingDelegate: self)
        } else {
            DDLogWarn("Unable to start Recording, no capture Session")
        }
    }

    open func stopRecording() {
        self.movieOutput?.stopRecording()

        DDLogInfo("Stop Recording of comment. stored at \(String(describing: self.tempFilePath))")
        self.captureSession?.stopRunning()
    }

}

extension Recorder: AVCaptureFileOutputRecordingDelegate {
    
    public func capture(_ captureOutput: AVCaptureFileOutput, didFinishRecordingToOutputFileAt outputFileURL: URL, fromConnections connections: [Any], error: Error?) {
        if let theError = error {
            DDLogError("Unable to save video to the iPhone  \(theError.localizedDescription)")
        } else {
            DDLogInfo("Did Finish Recording... could do something with it right now...")
        }
    }
}
