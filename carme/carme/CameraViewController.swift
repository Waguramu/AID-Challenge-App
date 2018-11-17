//
//  CameraViewController.swift
//  carme
//
//  Created by Wagram Airian on 17.11.18.
//  Copyright © 2018 Wagram Airian. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewControllerSwift: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBAction func didTakePhoto(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
}
