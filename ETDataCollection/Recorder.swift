import CocoaLumberjack
import AVFoundation

class Recorder : NSObject {
    var movieOutput:AVCaptureMovieFileOutput?
    
    init(movieOutput: AVCaptureMovieFileOutput) {
        self.movieOutput = movieOutput
    }
    
    open func startRecording(tempFilePath: URL) {
        movieOutput?.startRecording(toOutputFileURL: tempFilePath, recordingDelegate: self)
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
