//
//  AvatarVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 01/03/2024.
//

import UIKit
import Photos
import FirebaseStorage
import FirebaseAuth

class AvatarVC: UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var changeBt: UIButton!
    
    @IBOutlet weak var doneBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var backBt: UIButton!
        
    var imagePicker: UIImagePickerController!
    
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAvatar(button: doneBt, scrollView: scrollView, avatar: avatarImage, avatarBorder: avatarBorder)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    private func uploadMedia(completion: @escaping (_ url: String?) -> Void) {
        showLoading(isShow: true, view: view)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        if let avatarImageData = self.avatarImage.image?.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("avatars").child("\(uid).jpg")
            
            storageRef.putData(avatarImageData, metadata: nil) { metadata, error in
                guard let _ = metadata else {
                    print("Lỗi khi tải ảnh avatar lên: \(error?.localizedDescription ?? "Lỗi không xác định")")
                    return
                }
                showLoading(isShow: false, view: self.view)
            }
        } else {
            print("Lỗi: Không thể chuyển đổi ảnh avatar thành dữ liệu.")
        }
        
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        
        switch sender {
        case changeBt:
            print("Change Avatar!")
            
            let alert = UIAlertController(title: "Foto", message: "Chọn ảnh từ", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
            let camera = UIAlertAction(title: "Máy ảnh", style: .default, handler: { (_) in
                self.fromCamera()
            })
            let libray = UIAlertAction(title: "Thư viện", style: .default, handler: { (_) in
                self.fromLibrary()
            })
            
            alert.addAction(camera)
            alert.addAction(libray)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            
        case doneBt:
            print("Done Button Tapped!")
            
            uploadMedia() { url in
                guard let url = url else { return }
            }
            
            let avatar: UIImageView? = avatarImage
            if avatar != nil {
                print("Change Avatar Successfully")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let connectVC = storyboard.instantiateViewController(withIdentifier: "ConnectVC") as! ConnectVC
                                
                self.navigationController?.pushViewController(connectVC, animated: true)
                
                self.navigationController?.isNavigationBarHidden = true
                
            } else {
                let alert = UIAlertController(title: "Lỗi", message: "Chưa có ảnh avatar", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            }
            
        case backBt:
            print("Back Back!!")
            
            let previousVC = (self.navigationController?.viewControllers[4])
            
            self.navigationController?.popToViewController(previousVC!, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
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
    
}

extension AvatarVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            self.avatarImage.image = img
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.avatarImage.image = img
        }

        picker.dismiss(animated: true,completion: nil)
    }
}
