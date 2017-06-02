//
//  ViewController.swift
//  ETDataCollection
//
//  Created by Jones, Morgan on 5/19/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var guideRectCALayer:CALayer?
    var foo:Foo?

<<<<<<< HEAD
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
=======
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

>>>>>>> develop

        foo = Foo.init(viewController:self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
=======
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processRecordingPermission), name: NSNotification.Name(rawValue: self.recordingPermissionCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        
        if let previewView = self.previewView {
            previewView.isHidden = true
        }
>>>>>>> develop

        foo?.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
<<<<<<< HEAD
        foo?.viewDidAppear(animated)
=======
        self.setupResult = .initializing
        self.checkVideoPermission() // Starts a chain of permission checks that ends in a notification where a check is made on how to proceed

        
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
            
            if let theError = err {
                DDLogError("error: \(theError.localizedDescription)")
            }
            if let aPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                aPreviewLayer.frame = self.view.bounds
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
>>>>>>> develop
    }
}
