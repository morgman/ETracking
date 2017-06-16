//
//  MetaDataCollectionViewController.swift
//  ETDataCollection
//
//  Created by Jones, Morgan on 6/16/17.
//  Copyright © 2017 Jones, Morgan. All rights reserved.
//

import UIKit
import AVFoundation
import CocoaLumberjack
import Photos



class MetaDataCollectorViewController: UIViewController {
    
    @IBOutlet weak var widthTextField: UITextField?
    @IBOutlet weak var heightTextField: UITextField?

    @IBAction func startTapped(_ sender: Any) {
        
        DDLogInfo("StartTapped")
        
        if let widthField = self.widthTextField, let heightField = self.heightTextField, let widthValueString = widthField.text, let heightValueString = heightField.text {
            if let widthValue = NumberFormatter().number(from: widthValueString),  let heightValue = NumberFormatter().number(from: heightValueString) {
                
            DDLogInfo("Testing Width and height \(widthValue),\(heightValue)")
            
            if let aCameraViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                aCameraViewController.navigationController?.isNavigationBarHidden = true
                aCameraViewController.gridWidth = CGFloat(widthValue)
                aCameraViewController.gridHeight = CGFloat(heightValue)
                self.navigationController?.pushViewController(aCameraViewController, animated: true)
            } else {
                DDLogWarn("Unable to display camera viewcontroller.")
            }
            } else {
                DDLogWarn("No valid width and/or height")
            }

        } else {
            DDLogWarn("Unable to collect height and width, nil outlets")
        }
    
        
        
    
    }

}
