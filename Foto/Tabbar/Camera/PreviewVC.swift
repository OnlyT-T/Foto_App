//
//  PreviewVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseDatabaseInternal
import FirebaseFirestoreInternal

class PreviewVC: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var imageBorder: UIView!
    
    @IBOutlet weak var moveBt: UIButton!
    
    @IBOutlet weak var editCaption: UIButton!
    
    @IBOutlet weak var captionView: UIView!
    
    @IBOutlet weak var captionLb: UILabel!
    
    @IBOutlet weak var editCapBt: UIButton!
        
    @IBOutlet weak var sentView: UIView!
    
    let db = Firestore.firestore()
    
    var imageHandler: UIImage?
    
    var newImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    
    private func setUp() {
        moveBt.layer.cornerRadius = moveBt.frame.size.height/2
        moveBt.layer.masksToBounds = false
        moveBt.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        moveBt.layer.shadowOpacity = 0.25
        moveBt.layer.shadowOffset = .zero
        moveBt.layer.shadowRadius = 32
        
        imageBorder.layer.cornerRadius = 20
        
        captionView.layer.cornerRadius = 16
        captionView.layer.masksToBounds = false
        captionView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        captionView.layer.shadowOpacity = 0.25
        captionView.layer.shadowOffset = .zero
        captionView.layer.shadowRadius = 80
        
        sentView.layer.cornerRadius = sentView.frame.size.height/2
    }

    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case moveBt:
            let captureVC = CaptureVC()
            captureVC.modalPresentationStyle = .popover
            captureVC.popoverPresentationController?.permittedArrowDirections = .up
            captureVC.popoverPresentationController?.delegate = self
            captureVC.delegate = self
            self.present(captureVC, animated: true, completion: nil)
        
        case editCapBt:
            let alertController = UIAlertController(title: "Nhập tiêu đề", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Bạn muốn nhắn nhủ điều gì?"
            }
            let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                
                self.captionLb.text = textField.text
                self.captionLb.textColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
            })
            let cancelAction = UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    @objc func sentAction() {
        print("Sending in Progress")
        
        self.uploadMedia() { url in
            guard let _ = url else { return }
        }
    }
    
    private func uploadFotoRealtime(name: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        let caption = captionLb.text ?? ""
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        
        let docRef = db.collection("user").document(uid)
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error!!!")
                return
            }
            
            guard let conversationId = data["Conversation ID"] as? String else {
                return
            }
            
            let databaseRef = Database.database().reference().child("fotos").child(conversationId)
            
            guard let fotoId = databaseRef.childByAutoId().key else {
                return
            }
            
            let message: [String: Any] = ["liked": "False",
                                          "sender id": uid,
                                          "caption": caption,
                                          "image name": name,
                                          "time sent": date,
                                          "foto id": fotoId,
                                          "timestamp": Date().timeIntervalSince1970]
            
            databaseRef.child(fotoId).setValue(message)
        }
    }
    
    private func uploadMedia(completion: @escaping (_ url: String?) -> Void) {
        showLoading(isShow: true, view: imageBorder)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let docRef = db.collection("user").document(uid)
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error!!!")
                return
            }
            
            guard let index = data["My Fotos Count"] as? Int else {
                return
            }
            
            let newIndex = index + 1
            
            let imageName: String = "\(newIndex) - \(self.captionLb.text ?? "Error Caption").jpg"
            
            if let avatarImageData = self.imageHandler?.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("library").child(uid).child(imageName)
                
                storageRef.putData(avatarImageData, metadata: nil) { metadata, error in
                    guard let _ = metadata else {
                        print("Lỗi khi tải ảnh foto lên: \(error?.localizedDescription ?? "Lỗi không xác định")")
                        return
                    }
                    showLoading(isShow: false, view: self.imageBorder)
                    
                    let data: [String: Any] = [
                        "My Fotos Count": newIndex,
                    ]
                    
                    let docRef = self.db.collection("user").document(uid)
                    docRef.updateData(data) { error in
                        if let err = error {
                            print("Error update document: \(err)")
                        } else {
                            print("Update Successfully!!!")
                            
                            //Gọi hàm uploadFotoRealtime()
                            self.uploadFotoRealtime(name: imageName)
                            
                            let alert = UIAlertController(title: "Tuyệt cú mèo", message: "Foto đã được gửi thành công!", preferredStyle: .alert)
                            
                            let button = UIAlertAction(title: "Xác nhận", style: .cancel, handler: {(action:UIAlertAction!) in
                                self.clearPreview()
                            })

                            alert.addAction(button)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("Lỗi: Không thể chuyển đổi ảnh foto thành dữ liệu.")
                showLoading(isShow: false, view: self.imageBorder)
            }
        }
    }
    
    private func clearPreview() {
        imageHandler = nil
        newImage.removeFromSuperview()
        for subview in sentView.subviews {
            subview.removeFromSuperview()
        }
        captionLb.text = "Hãy nói gì đó về bức Foto này"
        captionLb.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
}

extension PreviewVC: CaptureVCDelegate {
    func didDismiss(with data: UIImage) {
        imageHandler = data
        newImage = UIImageView(image: data)
        imageBorder.addSubview(newImage)
        newImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newImage.topAnchor.constraint(equalTo: imageBorder.topAnchor),
            newImage.bottomAnchor.constraint(equalTo: imageBorder.bottomAnchor),
            newImage.trailingAnchor.constraint(equalTo: imageBorder.trailingAnchor),
            newImage.leadingAnchor.constraint(equalTo: imageBorder.leadingAnchor)
        ])
        
        let sentBt = UIButton(type: .custom)
        sentBt.setImage(UIImage(named: "Sent Button"), for: .normal)
        sentView.addSubview(sentBt)
        sentBt.translatesAutoresizingMaskIntoConstraints = false
        sentBt.layer.cornerRadius = sentBt.frame.size.height/2
        sentBt.addTarget(self, action: #selector(sentAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            sentBt.widthAnchor.constraint(equalToConstant: 100),
            sentBt.heightAnchor.constraint(equalToConstant: 100),
            sentBt.centerXAnchor.constraint(equalTo: sentView.centerXAnchor),
            sentBt.centerYAnchor.constraint(equalTo: sentView.centerYAnchor)
        ])
    }
}
