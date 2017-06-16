//
//  ViewController.swift
//  ETDataCollection
//
//  Created by Jones, Morgan on 5/19/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack
import Photos



class ViewController: UIViewController {

    @IBOutlet open weak var previewView: UIView?
    
    fileprivate enum SessionSetupResult {
        case initializing
        case success
        case videoNotAuthorized
        case audioNotAuthorized
        case photoLibraryNotAuthorized
        case configurationFailed
    }
    fileprivate var setupResult: SessionSetupResult = .success
    fileprivate var commentPlayer = AVPlayer()


    var gridWidth:CGFloat?
    var gridHeight:CGFloat?
    
    var stillImageOutput:AVCaptureStillImageOutput?
    var countdownTimer:Timer?
    var captureSession:AVCaptureSession?
    var captureDevice:AVCaptureDevice?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var faceRectCALayer:CALayer?
    var guideRectCALayer:CALayer?
    fileprivate var sessionQueue: DispatchQueue = DispatchQueue(label: "videoQueue", attributes: [])
    let recordingPermissionCompleted = "recordingPermissionCompleted"
    var movieOutput = AVCaptureMovieFileOutput()
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
    fileprivate func deviceInputFromDevice(_ device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
            print("Device setup error occured \(outError)")
            return nil
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processRecordingPermission), name: NSNotification.Name(rawValue: self.recordingPermissionCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        
        if let previewView = self.previewView {
            previewView.isHidden = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupResult = .initializing
        self.checkVideoPermission() // Starts a chain of permission checks that ends in a notification where a check is made on how to proceed

        
    }

    open func checkVideoPermission() {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            DDLogInfo("Already Authorized to access video")
            self.setupResult = .success
            self.checkPhotoLibraryPermission()

            //NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
            
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
                    self.checkPhotoLibraryPermission()

                    //NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
                }
            })
        default:
            // The user has previously denied access.
            self.setupResult = .videoNotAuthorized
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
        }
    }
    
    open func checkPhotoLibraryPermission() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        print(status)
        switch status {
        case .authorized:
            DDLogInfo("Already Authorized to access photo library")
            self.setupResult = .success
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
            
        case .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization({ [unowned self] granted in
                if granted == PHAuthorizationStatus.denied {
                    self.setupResult = .photoLibraryNotAuthorized
                } else {
                    DDLogInfo("Authorized to access photo library")
                    self.setupResult = .success
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
            })
        default:
            setupResult = .photoLibraryNotAuthorized
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.recordingPermissionCompleted), object: nil )
        }
    }

    
    open func processRecordingPermission(_ notification: Notification) {
        if self.setupResult == .success {
            DispatchQueue.main.async(execute: { () -> Void in
                DDLogInfo("Display Alert indicating Test should start")
                
                let videoFailedAlert = UIAlertController(title: "Permission Granted", message: "Start Testing Now...", preferredStyle: UIAlertControllerStyle.alert)
                videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                    DDLogWarn("Placeholder")
                    self.videoSetup()
//                    self.captureUserMovement()
                    
                }))
                
                self.present(videoFailedAlert, animated: true, completion: {
                })

            })
        } else {
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                let videoFailedAlert = UIAlertController(title: "Permission Denied", message: "User denied access to record video comment.", preferredStyle: UIAlertControllerStyle.alert)
                videoFailedAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                    DDLogWarn("Placeholder")
                }))
                
                self.present(videoFailedAlert, animated: true, completion: {
                })
                
            })
            
            
            DDLogError("Unable to record comment permission denied by user: \(self.setupResult)")
        }
    }
    
    func videoSetup() {
        
        DDLogInfo("Setting up Video")
        movieOutput = AVCaptureMovieFileOutput()
        DispatchQueue.main.async(execute: { () -> Void in
            
            let captureSession = AVCaptureSession()
            self.stillImageOutput = AVCaptureStillImageOutput()

            if let deviceSession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front) {
                captureSession.beginConfiguration()
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
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
                                
                                self.captureDevice = device
                            }
                        }
                    }
                }
            }
            captureSession.commitConfiguration()
            self.captureSession = captureSession
            self.beginSession()
        })
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
            
            if let stillImageOutput = self.stillImageOutput {
                stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                if captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addOutput(stillImageOutput)
                }
            } else {
                DDLogWarn("No Still Image Output available to add to capture Session")
            }
            
            if let theError = err {
                DDLogError("error: \(theError.localizedDescription)")
            }
            if let aPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                aPreviewLayer.frame = self.view.bounds
                aPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.previewLayer = aPreviewLayer
                captureSession.startRunning()
                
                self.captureUserMovement() // TODO:  Added here just to insure order of operations worked out correctly, where should it go?

            } else {
                DDLogWarn("Unable to create an AVCaptureCideoPreviewLayer")
            }
        } else {
            DDLogWarn("recorder variables null unable to begin session.")
        }
    }
    
    func startRecording() {
        if let _ = self.captureSession {
            movieOutput.startRecording(toOutputFileURL: tempFilePath, recordingDelegate: self)
        } else {
            DDLogWarn("Unable to start Recording, no capture Session")
        }
    }
    
    func stopRecording() {
        
        movieOutput.stopRecording()
        
        DDLogInfo("Stop Recording of comment. stored at \(self.tempFilePath)")
        self.captureSession?.stopRunning()
    }

    
    open func itemDidFinishPlaying(_ notification: Notification) {
        if let previewView = self.previewView {
            previewView.isHidden = true
        }
    }
    
    func endEyeTracking() {
        self.stopRecording()
        
        
        
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
            
            self.present(videoFailedAlert, animated: true, completion: {
            })
            
        })

    }
    
    open func captureUserMovement() {
        
        self.startRecording()
        countdownTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(endEyeTracking), userInfo: nil, repeats: false)
    }
}

extension ViewController:  AVCaptureMetadataOutputObjectsDelegate {
    
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
            let maxFaceRect = self.findMaxFaceRect(faces)
            
            if let videoConnection = self.stillImageOutput, let validatedConnection = videoConnection.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.captureStillImageAsynchronously(from: validatedConnection) {
                    (imageDataSampleBuffer, error) -> Void in
                    
                    if let validatedError = error {
                        DDLogWarn("Error capturing Still Image error = \(validatedError)")

                    } else {
                    if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                        if let validUIImage = UIImage(data: imageData) {
                            UIImageWriteToSavedPhotosAlbum(validUIImage, nil, nil, nil)
                        } else {
                            DDLogWarn("Valid UIImage could not be created from data")
                        }
                    } else {
                        DDLogWarn("No Image Data to save")
                    }
                    }
                }
            }
            
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

extension ViewController:  AVCaptureFileOutputRecordingDelegate {
    
    public func capture(_ captureOutput: AVCaptureFileOutput, didStartRecordingToOutputFileAt fileURL: URL, fromConnections connections: [Any]) {
    }
    
    public func capture(_ captureOutput: AVCaptureFileOutput, didFinishRecordingToOutputFileAt outputFileURL: URL, fromConnections connections: [Any], error: Error?) {
        if let theError = error {
            DDLogError("Unable to save video to the iPhone  \(theError.localizedDescription)")
        } else {
            DDLogInfo("Did Finish Recording... could do something with it right now...")
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let theWidth = self.gridWidth {
            return Int(theWidth)
        } else {
            return 2
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if let theHeight = self.gridHeight {
            return Int(theHeight)
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as? TestCollectionViewCell {
            
            return aCell
        }
        return UICollectionViewCell.init()
    }
    
    func collectionView(collectionView: UICollectionView!, layout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
     
        guard let theWidth = self.gridWidth, let theHeight = self.gridHeight else { return  CGSize(width:100, height:100) }
        
        let cellWidth = self.view.frame.width / theWidth
        let cellHeight = self.view.frame.height / theHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }

}
