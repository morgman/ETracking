import AVFoundation
import CocoaLumberjack

struct SketchAnimation {
    // represents some fully-generated animation that's ready to play by the end user
}

class Foo : NSObject {
    let recordingPermissionCompleted = "recordingPermissionCompleted"

    var faceRectCALayer:CALayer?
    var countdownTimer:Timer?
    var captureSession:AVCaptureSession?
    var movieOutput = AVCaptureMovieFileOutput()
    var captureDevice:AVCaptureDevice?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var alert:((_ view: UIViewController) -> Void)?
    var previewView: UIView?
    var bounds: CGRect?
    var recorder: Recorder?
    
    fileprivate var commentPlayer = AVPlayer()
    fileprivate var sessionQueue: DispatchQueue = DispatchQueue(label: "videoQueue", attributes: [])
    fileprivate var setupResult: SessionSetupResult = .success
    fileprivate var tempFilePath: URL = {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmpComment").appendingPathExtension("mp4")
        if FileManager.default.fileExists(atPath: tempPath.absoluteString) {
            do {
                try FileManager.default.removeItem(atPath: tempPath.absoluteString)
            } catch { }
        }
        return tempPath
        //        } else {
        //            return URL.init(string: "")
        //        }
    }()

    fileprivate enum SessionSetupResult {
        case initializing
        case success
        case videoNotAuthorized
        case audioNotAuthorized
        case photoLibraryNotAuthorized
        case configurationFailed
    }

    fileprivate func deviceInputFromDevice(_ device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
            print("Device setup error occured \(outError)")
            return nil
        }
    }

    init(alert: @escaping (_ view: UIViewController) -> Void) {
        self.alert = alert
    }

    open func viewDidLoad(bounds:CGRect, previewView:UIView) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.processRecordingPermission), name: NSNotification.Name(rawValue: self.recordingPermissionCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.bounds = bounds
        self.previewView = previewView
        if let previewView = self.previewView {
            previewView.isHidden = true
        }
    }

    open func itemDidFinishPlaying(_ notification: Notification) {
        if let previewView = self.previewView {
            previewView.isHidden = true
        }
    }
    
    open func viewDidAppear(_ animated: Bool) {
        self.setupResult = .initializing
        self.checkVideoPermission() // Starts a chain of permission checks that ends in a notification where a check is made on how to proceed
    }

    open func processRecordingPermission(_ notification: Notification) {
        if self.setupResult == .success {
            DispatchQueue.main.async(execute: { () -> Void in
                DDLogInfo("Display Alert indicating Test should start")
                
                let videoFailedAlert = UIAlertController(
                    title: "Permission Granted",
                    message: "Start Testing Now...",
                    preferredStyle: UIAlertControllerStyle.alert)

                videoFailedAlert.addAction(UIAlertAction(
                    title: "Ok",
                    style: .default,
                    handler: { (action: UIAlertAction) in
                        DDLogWarn("Placeholder")
                        self.videoSetup()
                        self.captureUserMovement()
                    }
                ))
                
                self.alert!(videoFailedAlert)
            })
        } else {
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                let videoFailedAlert = UIAlertController(title: "Permission Denied", message: "User denied access to record video comment.", preferredStyle: UIAlertControllerStyle.alert)
                videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                    DDLogWarn("Placeholder")
                }))
                
                self.alert!(videoFailedAlert)
            })
            
            
            DDLogError("Unable to record comment permission denied by user: \(self.setupResult)")
        }
    }
    
    func beginSession() {
        DDLogInfo("Beginning Video Session")
        let err : NSError? = nil
        if let captureSession = self.captureSession, let captureDevice = self.captureDevice {
            
            captureSession.addInput(self.deviceInputFromDevice(captureDevice)) //(cDevice)  //AVCaptureDeviceInput(device: captureDevice, error: &err))
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
                metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
                DDLogInfo("Added CaptureMetadatOutput")
            } else {
                DDLogWarn("Cannot add metadataOutput to capture Session")
            }
            captureSession.addOutput(self.movieOutput)
            
            if let theError = err {
                DDLogError("error: \(theError.localizedDescription)")
            }
            if let aPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                aPreviewLayer.frame = bounds!
                aPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.previewLayer = aPreviewLayer
                captureSession.startRunning()
                self.captureUserMovement()
            } else {
                DDLogWarn("Unable to create an AVCaptureCideoPreviewLayer")
            }
        } else {
            DDLogWarn("recorder variables null unable to begin session.")
        }
    }

    func endEyeTracking() {
        recorder?.stopRecording()
        
        DispatchQueue.main.async(execute: { () -> Void in
            if let previewView = self.previewView {
                previewView.isHidden = false
                self.commentPlayer = AVPlayer()
                self.commentPlayer = AVPlayer.init(url: self.tempFilePath)//[AVPlayer playerWithURL:fileURL];
                self.commentPlayer.actionAtItemEnd = .none

                let aPlayerLayer = AVPlayerLayer.init(player: self.commentPlayer)
                aPlayerLayer.backgroundColor = UIColor.blue.cgColor
                previewView.layer.addSublayer(aPlayerLayer)
                aPlayerLayer.frame = previewView.bounds
                aPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.commentPlayer.play()
            }

            let videoFailedAlert = UIAlertController(title: "Recording complete", message: "View recording at \(self.tempFilePath)", preferredStyle: UIAlertControllerStyle.alert)
            videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                DDLogWarn("Placeholder")
            }))
            
            self.alert!(videoFailedAlert)
        })
        
    }

    open func captureUserMovement() {
        recorder?.startRecording()
        countdownTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(endEyeTracking), userInfo: nil, repeats: false)
    }

    open func checkVideoPermission() {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            DDLogInfo("Already Authorized to access video")
            self.setupResult = .success
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .videoNotAuthorized
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
                } else {
                    self.setupResult = .success
                    DDLogInfo("Authorized to access video")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
                }
            })
        default:
            // The user has previously denied access.
            self.setupResult = .videoNotAuthorized
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
        }
    }

    func videoSetup() {
        DDLogInfo("Setting up Video")
        DispatchQueue.main.async(execute: { () -> Void in
            self.captureDevice = DeviceUtil().getFrontCameraDevice()

            let captureSession = AVCaptureSession()
            captureSession.beginConfiguration ()
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            captureSession.commitConfiguration()
            self.captureSession = captureSession

            self.recorder = Recorder(
                captureSession: self.captureSession!,
                movieOutput: self.movieOutput,
                tempFilePath: self.tempFilePath)

            self.beginSession()
        })
    }
}

extension Foo: AVCaptureMetadataOutputObjectsDelegate {
    
    public func captureOutput(_ captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: [Any], from connection: AVCaptureConnection) {
        
        var faces = [CGRect]()
        
        for aMetaDataObject in metadataObjects {
            if let metadataObject = aMetaDataObject as? AVMetadataObject, let previewLayer = self.previewLayer {
                if metadataObject.type == AVMetadataObjectTypeFace {
                    if let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject) {
                        let face = transformedMetadataObject.bounds
                        faces.append(face)
                    }
                }
            } else {
                DDLogWarn("Can't find faces in metadata, somethings nil")
            }
        }
        
        if faces.count > 0 {
            DDLogInfo("Face Count == \(faces.count)")
            //            var newColor = UIColor.red.cgColor
            //            var newWidth:CGFloat = 3.0
            _ = self.findMaxFaceRect(faces)
            //            if let recorderGuideView = self.recorderGuideView {
            //                let faceGuideIntersection = recorderGuideView.frame.intersection(maxFaceRect)
            //                if faceGuideIntersection != CGRect.null {
            //                    let intersectionArea = faceGuideIntersection.width * faceGuideIntersection.height
            //                    let guideArea = recorderGuideView.frame.size.width * recorderGuideView.frame.height
            //                    let percentInGuide = Float(intersectionArea / guideArea)
            //                    let greaterThanThreshold = (percentInGuide > 0.7)
            //                    DDLogInfo("Face percent in guide \(percentInGuide) exceedsThreshold? \(greaterThanThreshold)")
            //                    if greaterThanThreshold == true {
            //                        newColor = UIColor.green.cgColor
            //                        newWidth = 1.0
            //                    } else {
            //                        newColor = UIColor.red.cgColor
            //                        newWidth = 3.0
            //                    }
            //                }
            //            }
            
        } else {
            DDLogInfo("Face Count == 0")
        }
    }
    
    func setlayerHidden(_ hidden: Bool) {
        
        if let faceRectCALayer = self.faceRectCALayer {
            if (faceRectCALayer.isHidden != hidden){
                DispatchQueue.main.async(execute: {
                    () -> Void in
                    faceRectCALayer.isHidden = hidden
                })
            }
        }
    }
    
    func findMaxFaceRect(_ faces : Array<CGRect>) -> CGRect {
        if (faces.count == 1) {
            return faces[0]
        }
        var maxFace = CGRect.zero
        var maxFace_size = maxFace.size.width + maxFace.size.height
        for face in faces {
            let face_size = face.size.width + face.size.height
            if (face_size > maxFace_size) {
                maxFace = face
                maxFace_size = face_size
            }
        }
        return maxFace
    }
}
