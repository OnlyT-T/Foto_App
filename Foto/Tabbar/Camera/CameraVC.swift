//
//  CameraVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/03/2024.
//

import UIKit

class CameraVC: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var cameraBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraBt.layer.cornerRadius = cameraBt.frame.size.height/2
    }

    @IBAction func actionTapped(_ sender: UIButton) {
        let uploadVC = UploadPhotoVC()
        uploadVC.modalPresentationStyle = .popover
        uploadVC.popoverPresentationController?.sourceView = sender
        uploadVC.popoverPresentationController?.permittedArrowDirections = .up
        uploadVC.popoverPresentationController?.delegate = self
        self.present(uploadVC, animated: true, completion: nil)
    }
    
}
