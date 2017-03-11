//
//  ViewController.swift
//  OpenCVT
//
//  Created by Zel Marko on 18/02/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {


    
let session = AVCaptureSession()
let previewLayer = AVCaptureVideoPreviewLayer()

    
    @IBOutlet weak var platno: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraSetup()
    }
    // MARK: - Preview Setup
    /**
    Setup for the live preview and sampleBuffer.
    */
    func cameraSetup() {
        
        let availableCameraDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        var backCameraDevice: AVCaptureDevice?
        var frontCameraDevice: AVCaptureDevice?
        
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .back {
                backCameraDevice = device
            }
            else if device.position == .front {
                frontCameraDevice = device
            }
        }
        
        var error: NSError?
        do {
            let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput(device: backCameraDevice) as AVCaptureDeviceInput
            
            if let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
                if session.canAddInput(backCameraInput) {
                    session.addInput(backCameraInput)
                }
            }
        }
        catch let error as NSError { print(error) }
    
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted {
                    
                }
                else {
                    
                }
                
            })
        case .authorized:
            print("")
        case .denied, .restricted:
            print("")
        }
        previewLayer.session = session
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
//        videoOutput.videoSettings = NSDictionary(objectsAndKeys: Int(kCVPixelFormatType_32BGRA),
//            kCVPixelBufferPixelFormatTypeKey)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: Int(kCVPixelFormatType_32BGRA)]
        
        session.startRunning()
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
    
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        let img: UIImage = CVWrapper.image(from: sampleBuffer)
        print(img.size)
        
        
        
        if img.size.height != 0 {
            previewLayer.removeFromSuperlayer()
            let scaledImage = rotateImage(scaleImage(img, maxDimension: 640), degrees: 0)
            performImageRecognition(scaledImage)
            session.stopRunning()
            DispatchQueue.main.sync(execute: {
                self.platno.image = scaledImage
                self.platno.bringSubview(toFront: self.platno)
            })
        }
    }
    // MARK: - Tesseract
    /**
    Perfroms character recognition on the detected rectangle we get from OpenCV.

    - parameter image: The input image on which the recognition is done.
    */
    func performImageRecognition(_ image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        if let text = tesseract.recognizedText {
            print("Recognized text: \(tesseract.recognizedText)")
        }
        else {
            print("No text recognized.")
        }
        
    }
    /**
    Scales image to the selected maximal dimension with the original aspect ratio.

    - parameter image: Image to scale.
    - parameter maxDimension: preffered maximal dimension of width or height.

    - returns: UIImage Scaled image.
    */
    func scaleImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension);
        var scaleFactor: CGFloat
        
        let width = image.size.width
        let height = image.size.height
        
        if width > height {
            scaleFactor = height / width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.height * scaleFactor
        }
        else {
            scaleFactor = width / height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func rotateImage(_ image: UIImage, degrees: CGFloat) -> UIImage {
        
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: image.size))
        let t = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        bitmap?.rotate(by: degreesToRadians(degrees))
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage!
    }

}

