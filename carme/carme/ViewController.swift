//
//  ViewController.swift
//  carme
//
//  Created by Wagram Airian on 16.11.18.
//  Copyright © 2018 Wagram Airian. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let locationManager = CLLocationManager()
    
    let speechText = "The car will be available at your location in several minutes!"
    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            else {
                print("Unable to access front camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }

    @IBAction func didTakePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)!
        // Send image
        if myImageUploadRequest(image: image) {
            self.tellUser(text: speechText)
        }
    }
    
    func getLocation() -> String {
        return "\(String(describing: self.locationManager.location?.coordinate.latitude))" + " : " + "\(String(describing: self.locationManager.location?.coordinate.longitude))"
    }
    
    func myImageUploadRequest(image: UIImage) -> Bool {
        
        var request = URLRequest(url: URL(string: "http://131.159.197.92:8080")!)
        request.httpMethod = "POST"
        let location = getLocation()
        print("Location: \(location)")
        let params: Dictionary = ["location": location]
        request.httpBody = self.createRequestBodyWith(parameters: params as [String : NSObject], image: image, boundary: self.generateBoundaryString()).base64EncodedData()
        print("Request")
        print(request)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse
            {
                print(response.statusCode)
            }
            if let data = data
            {
                let json = String(data: data, encoding: String.Encoding.utf8)
                print("Response data: \(String(describing: json))")
            }
        }
        print("Task")
        print(task)
        task.resume()
        return true
    }
    
    
    func createRequestBodyWith(parameters:[String:NSObject], image:UIImage, boundary:String) -> Data {
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
        
        body.append(Data("--\(boundary)\r\n".utf8))
        
        let mimetype = "image/jpg"
        
        let defFileName = "selfie.jpg"
        
        let imageData = image.jpegData(compressionQuality: 1)
        
        body.append(Data("Content-Disposition: form-data; name=\"selfie\"; filename=\"\(defFileName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageData!)
        body.append(Data("\r\n".utf8))
        
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        print(Data("--\(boundary)--\r\n".utf8).base64EncodedString())
        print("Body")
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func tellUser(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
}
