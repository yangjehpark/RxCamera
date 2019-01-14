//
//  ViewController.swift
//  RxCamera
//
//  Created by LinePlus on 2019. 1. 14..
//  Copyright © 2019년 yangjehpark. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var preview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func buttonPressed() {
        CameraManager.shared.openCamera(preview: preview) { (error) in
            
        }
//        CameraManager.shared.open2Camera(preview: preview)
    }
}

