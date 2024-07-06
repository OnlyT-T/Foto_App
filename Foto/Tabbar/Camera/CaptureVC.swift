//
//  CaptureVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 05/07/2024.
//

import UIKit
import AVFoundation
import CameraButton

protocol CaptureVCDelegate: AnyObject {
    func didDismiss(with data: UIImage)
}

class CaptureVC: UIViewController {

    @IBOutlet weak var cameraHandler: UIView!
    
    @IBOutlet weak var shutterView: UIView!
    
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var secondView: UIView!
    
    weak var delegate: CaptureVCDelegate?
        
    var previewStatus: Bool = false
    
    var flashStatus: Bool = false
    
    var session: AVCaptureSession?

    let output = AVCapturePhotoOutput()

    let previewLayer = AVCaptureVideoPreviewLayer()
    
//    var currentCamera: AVCaptureDevice!
//    
//    var captureDeviceInput: AVCaptureDeviceInput!
//    
//    var isUsingFrontCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shutterView.layer.cornerRadius = shutterView.frame.size.height/2
        firstView.layer.cornerRadius = firstView.frame.size.height/2
        secondView.layer.cornerRadius = secondView.frame.size.height/2
        cameraHandler.layer.cornerRadius = 20
        cameraHandler.layer.masksToBounds = true
        cameraHandler.layer.shadowColor = #colorLiteral(red: 1, green: 0.9999999404, blue: 0.9999999404, alpha: 1)
        cameraHandler.layer.shadowOpacity = 0.25
        cameraHandler.layer.shadowOffset = .zero
        cameraHandler.layer.shadowRadius = 80
        
        statusCheck()
        cameraHandler.layer.addSublayer(previewLayer)
        checkCameraPermissions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraHandler.bounds
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            
            catch {
                print(error)
            }
        }
    }
    
    private func statusCheck() {
        if previewStatus {
            print("In Preview Mode")
            
            let confirmBt = UIButton(type: .custom)
            confirmBt.setImage(UIImage(named: "Confirm"), for: .normal)
            shutterView.addSubview(confirmBt)
            confirmBt.translatesAutoresizingMaskIntoConstraints = false
            confirmBt.layer.cornerRadius = confirmBt.frame.size.height/2
            confirmBt.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
            
            let cancelBt = UIButton(type: .custom)
            cancelBt.setImage(UIImage(named: "Cancel"), for: .normal)
            firstView.addSubview(cancelBt)
            cancelBt.translatesAutoresizingMaskIntoConstraints = false
            cancelBt.layer.cornerRadius = cancelBt.frame.size.height/2
            cancelBt.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            
            let downloadBt = UIButton(type: .custom)
            downloadBt.setImage(UIImage(named: "Download"), for: .normal)
            secondView.addSubview(downloadBt)
            downloadBt.translatesAutoresizingMaskIntoConstraints = false
            downloadBt.layer.cornerRadius = downloadBt.frame.size.height/2
            downloadBt.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                confirmBt.widthAnchor.constraint(equalToConstant: 92),
                confirmBt.heightAnchor.constraint(equalToConstant: 92),
                confirmBt.centerXAnchor.constraint(equalTo: shutterView.centerXAnchor),
                confirmBt.centerYAnchor.constraint(equalTo: shutterView.centerYAnchor),
                cancelBt.widthAnchor.constraint(equalToConstant: 60),
                cancelBt.heightAnchor.constraint(equalToConstant: 60),
                cancelBt.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
                cancelBt.centerYAnchor.constraint(equalTo: firstView.centerYAnchor),
                downloadBt.widthAnchor.constraint(equalToConstant: 60),
                downloadBt.heightAnchor.constraint(equalToConstant: 60),
                downloadBt.centerXAnchor.constraint(equalTo: secondView.centerXAnchor),
                downloadBt.centerYAnchor.constraint(equalTo: secondView.centerYAnchor)
            ])
            
        } else {
            print("In Camera Mode")
            
            let shutterButton = CameraButton()
            shutterButton.delegate = self
            shutterView.addSubview(shutterButton)
            shutterButton.translatesAutoresizingMaskIntoConstraints = false
            
            let flashBt = UIButton(type: .custom)
            flashBt.setImage(UIImage(named: "Flash"), for: .normal)
            firstView.addSubview(flashBt)
            flashBt.translatesAutoresizingMaskIntoConstraints = false
            flashBt.layer.cornerRadius = flashBt.frame.size.height/2
            flashBt.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
            
            let switchBt = UIButton(type: .custom)
            switchBt.setImage(UIImage(named: "SwitchCam"), for: .normal)
            secondView.addSubview(switchBt)
            switchBt.translatesAutoresizingMaskIntoConstraints = false
            switchBt.layer.cornerRadius = switchBt.frame.size.height/2
            switchBt.addTarget(self, action: #selector(switchAction), for: .touchUpInside)

            NSLayoutConstraint.activate([
                shutterButton.widthAnchor.constraint(equalToConstant: 92),
                shutterButton.heightAnchor.constraint(equalToConstant: 92),
                shutterButton.centerXAnchor.constraint(equalTo: shutterView.centerXAnchor),
                shutterButton.centerYAnchor.constraint(equalTo: shutterView.centerYAnchor),
                flashBt.widthAnchor.constraint(equalToConstant: 40),
                flashBt.heightAnchor.constraint(equalToConstant: 40),
                flashBt.centerXAnchor.constraint(equalTo: firstView.centerXAnchor),
                flashBt.centerYAnchor.constraint(equalTo: firstView.centerYAnchor),
                switchBt.widthAnchor.constraint(equalToConstant: 40),
                switchBt.heightAnchor.constraint(equalToConstant: 40),
                switchBt.centerXAnchor.constraint(equalTo: secondView.centerXAnchor),
                switchBt.centerYAnchor.constraint(equalTo: secondView.centerYAnchor)
            ])

            shutterButton.borderColor = .white
            shutterButton.fillColor = (.white, .white)
            
            shutterButton.progressDuration = 2
        }
    }
    
    @objc func flashAction() {
        print("Flash")
        
        if flashStatus {
            toggleTorch(on: false)
            flashStatus = false
        } else {
            toggleTorch(on: true)
            flashStatus = true
        }
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { print("Torch isn't available"); return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            // Optional thing you may want when the torch it's on, is to manipulate the level of the torch
            if on { try device.setTorchModeOn(level: 1.0) }
            device.unlockForConfiguration()
        } catch {
            print("Torch can't be used")
        }
    }
    
    @objc func switchAction() {
        print("Switch Camera")
        
//        session!.beginConfiguration()
//        
//        let newCamera: AVCaptureDevice
//        if isUsingFrontCamera {
//            newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
//        } else {
//            newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
//        }
//        
//        session!.removeInput(captureDeviceInput)
//        
//        do {
//            captureDeviceInput = try AVCaptureDeviceInput(device: newCamera)
//            session!.addInput(captureDeviceInput)
//            currentCamera = newCamera
//        } catch {
//            print("Error switching cameras: \(error)")
//        }
//        
//        session!.commitConfiguration()
//        
//        isUsingFrontCamera.toggle()
        
        let alert = UIAlertController(title: "Thông báo", message: "Tính năng đang được phát triển. Xin vui lòng thử lại sau.", preferredStyle: .alert)
        
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func confirmAction() {
        print("Confirm")
        
        if let croppedImage = getImage(from: cameraHandler) {
            print("Successfully Crop Image")

            delegate?.didDismiss(with: croppedImage)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getImage(from view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
    
    @objc func cancelAction() {
        print("Cancel")
        
        for subview in firstView.subviews {
            subview.removeFromSuperview()
        }
        for subview in secondView.subviews {
            subview.removeFromSuperview()
        }
        for subview in shutterView.subviews {
            subview.removeFromSuperview()
        }
        for subview in cameraHandler.subviews {
            subview.removeFromSuperview()
        }
        
        previewStatus = false
        statusCheck()
        session?.startRunning()
    }
    
    @objc func downloadAction() {
        print("Download")
        
        let alert = UIAlertController(title: "Thông báo", message: "Tính năng đang được phát triển. Xin vui lòng thử lại sau.", preferredStyle: .alert)
        
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
}

extension CaptureVC: CameraButtonDelegate, AVCapturePhotoCaptureDelegate {
    func didTap(_ button: CameraButton) {
        print("Did Tap")
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        for subview in shutterView.subviews {
            subview.removeFromSuperview()
        }
        for subview in firstView.subviews {
            subview.removeFromSuperview()
        }
        for subview in secondView.subviews {
            subview.removeFromSuperview()
        }
        previewStatus = true
        statusCheck()
    }
    
    func didFinishProgress() {
        print("Did Finish")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        session?.stopRunning()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = cameraHandler.bounds
        cameraHandler.addSubview(imageView)
    }
}
