//
//  CameraManager.swift
//  RxCamera
//
//  Created by LinePlus on 2019. 1. 14..
//  Copyright © 2019년 yangjehpark. All rights reserved.
//

import UIKit
import AVFoundation

class CameraManager: NSObject {
    
    static let shared = CameraManager()
    
    enum CameraState {
        case closed, opening, opened, closing
    }
    private(set) var state: CameraState = .closed
    private var cameraView: UIView!
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    func openCamera(preview: UIView, completionHandler: @escaping (Error?) -> Void) {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            // No video device found
            completionHandler(nil)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession!.addInput(input)
            
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput!.isHighResolutionCaptureEnabled = true
            
            captureSession!.addOutput(capturePhotoOutput!)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.frame = cameraView.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession!.startRunning()
            
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
    
    private var session: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    func open2Camera(preview: UIView) {
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        if let backCamera = AVCaptureDevice.default(for: .video) {
            var error: NSError?
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: backCamera)
            } catch let error1 as NSError {
                error = error1
                input = nil
                print(error!.localizedDescription)
            }
            if error == nil && session!.canAddInput(input) {
                session!.addInput(input)
                stillImageOutput = AVCapturePhotoOutput()
                //stillImageOutput!.outputSettings = [AVVideoCodecKey:  AVVideoCodecJPEG]
                if session!.canAddOutput(stillImageOutput!) {
                    session!.addOutput(stillImageOutput!)
                    captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                    captureVideoPreviewLayer!.videoGravity = .resizeAspect
                    captureVideoPreviewLayer!.connection?.videoOrientation = .portrait
                    preview.layer.addSublayer(videoPreviewLayer!)
                    session!.startRunning()
                } else {
                    print("no output line founded")
                }
            } else {
                print("no session founded")
            }
        } else {
            print("no back camera founded")
        }
    }
    
    func closeCamera() {
        
    }
    
    func askAutorization() {
        
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}

extension CameraManager: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            cameraView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            cameraView?.frame = barCodeObject!.bounds
        }
    }
}


extension UIInterfaceOrientation {
    
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
