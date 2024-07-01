//
//  UploadPhotoVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 20/06/2024.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseCore
import TOCropViewController
//import TOCropViewController_TOCropViewController

class UploadPhotoVC: UIViewController {

    @IBOutlet weak var fotoImage: UIImageView!
    
    @IBOutlet weak var captionView: UIView!
    
    @IBOutlet weak var captionLb: UILabel!
    
    @IBOutlet weak var sendingBt: UIButton!
    
    @IBOutlet weak var editCaptionBt: UIButton!
    
    @IBOutlet weak var uploadImage: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    private func setUp() {
        captionView.layer.cornerRadius = 16
        captionView.layer.masksToBounds = false
        captionView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        captionView.layer.shadowOpacity = 0.25
        captionView.layer.shadowOffset = .zero
        captionView.layer.shadowRadius = 100
        
        uploadImage.layer.cornerRadius = 10
        uploadImage.layer.masksToBounds = false
        uploadImage.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        uploadImage.layer.shadowOpacity = 0.25
        uploadImage.layer.shadowOffset = .zero
        uploadImage.layer.shadowRadius = 100
        
        sendingBt.layer.cornerRadius = 16
        sendingBt.layer.masksToBounds = false
        sendingBt.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        sendingBt.layer.shadowOpacity = 0.25
        sendingBt.layer.shadowOffset = .zero
        sendingBt.layer.shadowRadius = 100
        
        sendingBt.layer.cornerRadius = sendingBt.frame.size.height/2
        
        fotoImage.layer.cornerRadius = 20
        fotoImage.layer.masksToBounds = true
    }
    
    private func uploadFotoRealtime(name: String) {
        // Sử dụng Realtime để upload caption với tên ảnh (.jpg)
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        let caption = captionLb.text ?? ""
        let date = String(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        
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
                                          "timestamp": ServerValue.timestamp()]
            
            databaseRef.child(fotoId).setValue(message)
        }
    }
    
    private func uploadMedia(completion: @escaping (_ url: String?) -> Void) {
        showLoading(isShow: true, view: view)
        
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
            
            if let avatarImageData = self.fotoImage.image?.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference().child("library").child(uid).child(imageName)
                
                storageRef.putData(avatarImageData, metadata: nil) { metadata, error in
                    guard let _ = metadata else {
                        print("Lỗi khi tải ảnh foto lên: \(error?.localizedDescription ?? "Lỗi không xác định")")
                        return
                    }
                    showLoading(isShow: false, view: self.view)
                    
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
                            
                            let alert = UIAlertController(title: "YAY", message: "Successfully upload your foto!", preferredStyle: .alert)
                            
                            let button = UIAlertAction(title: "OK", style: .cancel, handler: {(action:UIAlertAction!) in
                                self.dismiss(animated: true, completion: nil)
                            })

                            alert.addAction(button)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("Lỗi: Không thể chuyển đổi ảnh foto thành dữ liệu.")
                showLoading(isShow: false, view: self.view)
            }
        }
    }
    
    func confirm(message: String, viewController: UIViewController?, success: @escaping () -> Void){
        let alert = UIAlertController(title: "My App", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            success()
        }
        alert.addAction(action)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Open setting photos của hệ điều hành
    func setting(){
        let message = "App cần truy cập máy ảnh và thư viện của bạn. Ảnh của bạn sẽ không được chia sẻ khi chưa được phép của bạn."
        confirm(message: message, viewController: self) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.openURL(settingsUrl)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        }
    }
    
    // MARK: - Lấy ảnh từ thư viện
    private func fromLibrary(){
        func choosePhoto(){
            DispatchQueue.main.async {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.imagePicker.modalPresentationStyle = .popover
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        // khai báo biến để lấy quyền truy cập
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            // quyền truy cập đã được cấp
            choosePhoto()
        }else if (status == PHAuthorizationStatus.denied) {
            // quyền truy cập bị từ chối
            setting()
        }else if (status == PHAuthorizationStatus.notDetermined) {
            // quyền truy cập chưa được xác nhận
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    choosePhoto()
                }else {
                    print("Không được cho phép truy cập vào thư viện ảnh")
                    DispatchQueue.main.async {
                        self.setting()
                    }
                }
            })
        } else if (status == PHAuthorizationStatus.restricted) {
            // Truy cập bị hạn chế, thông thường sẽ không xảy ra
            setting()
        }
    }
    
    // MARK: - Lấy ảnh từ camera
    private func fromCamera(){
        func takePhoto(){
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                DispatchQueue.main.async {
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker.cameraCaptureMode = .photo
                    self.imagePicker.cameraDevice = .front
                    self.imagePicker.modalPresentationStyle = .fullScreen
                    self.present(self.imagePicker, animated: true,completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Thông báo", message: "Không tìm thấy máy ảnh", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                takePhoto()
            } else {
                print("camera denied")
                self.setting()
            }
        }
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case sendingBt:
            print("Sending In Progress")
            self.uploadMedia() { url in
                guard let url = url else { return }
            }
            
        case editCaptionBt:
            print("Edit Caption")
            
            let alertController = UIAlertController(title: "Edit Caption", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Your Caption"
            }
            let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let textField = alertController.textFields![0] as UITextField
                
                self.captionLb.text = textField.text
                self.captionLb.textColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        case uploadImage:
            print("Upload Image")
            
            let alert = UIAlertController(title: "Foto", message: "Choose image from", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let camera = UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                self.fromCamera()
            })
            let libray = UIAlertAction(title: "Library", style: .default, handler: { (_) in
                self.fromLibrary()
            })
            
            alert.addAction(camera)
            alert.addAction(libray)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension UploadPhotoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let selectedImage = info[.originalImage] as? UIImage else {
//            print("error: \(info)")
//            return
//        }
//        
//        self.fotoImage.image = selectedImage
//        dismiss(animated: true, completion: nil)
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            self.fotoImage.image = img
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.fotoImage.image = img
        }

        picker.dismiss(animated: true,completion: nil)
    }
    
//    func presentCropViewController(image: UIImage) {
//      let cropViewController = CropViewController(image: image)
//      cropViewController.delegate = self
//      present(cropViewController, animated: true, completion: nil)
//    }
//
//    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//            // 'image' is the newly cropped version of the original image
//        }
}
