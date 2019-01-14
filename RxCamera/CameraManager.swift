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
    private var cameraView: UIView?
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    func openCamera(preview: UIView, completionHandler: @escaping (Error?) -> Void) {
        
        askAutorization { (isAutorized) in
            guard isAutorized else {
                completionHandler(nil)
                return
            }
            
            print("asdf")
        }
    }
    
    func closeCamera() {
        cameraView = nil
    }
    
    func askAutorization(completionHandler: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completionHandler(true)
        default:
            let alert = UIAlertController(title: "RxCamera", message: "Do you want?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                } else {
                    
                }
            }))
            if var topVC = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedVC = topVC.presentedViewController {
                    topVC = presentedVC
                }
                topVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
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
