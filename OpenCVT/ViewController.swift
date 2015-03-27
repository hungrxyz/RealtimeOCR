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
        
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var backCameraDevice: AVCaptureDevice?
        var frontCameraDevice: AVCaptureDevice?
        
        for device in availableCameraDevices as [AVCaptureDevice] {
            if device.position == .Back {
                backCameraDevice = device
            }
            else if device.position == .Front {
                frontCameraDevice = device
            }
        }
        
        var error: NSError?
        let possibleCameraInput: AnyObject? = AVCaptureDeviceInput.deviceInputWithDevice(backCameraDevice, error: &error)
        if let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput {
            if session.canAddInput(backCameraInput) {
               session.addInput(backCameraInput)
            }
        }
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted {
                    
                }
                else {
                    
                }
                
            })
        case .Authorized:
            println()
        case .Denied, .Restricted:
            println()
        }
        previewLayer.session = session
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        videoOutput.videoSettings = NSDictionary(objectsAndKeys: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferPixelFormatTypeKey)
        
        session.startRunning()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    
        connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        let img: UIImage = CVWrapper.imageFromSampleBuffer(sampleBuffer)
        println(img.size)
        
        
        
        if img.size.height != 0 {
            previewLayer.removeFromSuperlayer()
            let scaledImage = rotateImage(scaleImage(img, maxDimension: 640), degrees: 0)
            performImageRecognition(scaledImage)
            session.stopRunning()
            dispatch_sync(dispatch_get_main_queue(), {
                self.platno.image = scaledImage
                self.platno.bringSubviewToFront(self.platno)
            })
        }
    }
    // MARK: - Tesseract
    /**
    Perfroms character recognition on the detected rectangle we get from OpenCV.

    :param: image The input image on which the recognition is done.
    */
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        if let text = tesseract.recognizedText {
            println("Recognized text: \(tesseract.recognizedText)")
        }
        else {
            println("No text recognized.")
        }
        
    }
    /**
    Scales image to the selected maximal dimension with the original aspect ratio.

    :param: image Image to scale.
    :param: maxDimension preffered maximal dimension of width or height.

    :returns: UIImage Scaled image.
    */
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
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
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func rotateImage(image: UIImage, degrees: CGFloat) -> UIImage {
        
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: image.size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees))
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0)
        CGContextRotateCTM(bitmap, degreesToRadians(degrees))
        CGContextScaleCTM(bitmap, 1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), image.CGImage)
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }

}

