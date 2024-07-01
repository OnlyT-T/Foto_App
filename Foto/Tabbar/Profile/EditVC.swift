//
//  EditVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 07/06/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import Photos

class EditVC: UIViewController {
    
    @IBOutlet weak var myAvatar: UIImageView!
    
    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var changeAvatarBt: UIButton!
    
    @IBOutlet weak var nicknameTF: UITextField!
    
    @IBOutlet weak var tfBorder: UIView!
    
    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    var getCurrentName: String?
   
    var getAvatar: UIImage?
    
    let db = Firestore.firestore()
    
    var imagePicker: UIImagePickerController!
    
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        nicknameTF.text = getCurrentName
        myAvatar.image = getAvatar
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nicknameTF.becomeFirstResponder()
    }
    
    private func setUp() {
        avatarBorder.layer.cornerRadius = avatarBorder.frame.size.height/2
        avatarBorder.layer.masksToBounds = false
        avatarBorder.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        avatarBorder.layer.shadowOpacity = 0.25
        avatarBorder.layer.shadowOffset = .zero
        avatarBorder.layer.shadowRadius = 100
        myAvatar.layer.cornerRadius = myAvatar.frame.size.height/2
        
        nicknameTF.layer.cornerRadius = 18.0
        tfBorder.layer.cornerRadius = 20.0
        
        confirmBt.layer.cornerRadius = confirmBt.frame.size.height/2
        
        changeAvatarBt.layer.cornerRadius = changeAvatarBt.frame.size.height/2
        
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func updateProcess() {
        let nickname = nicknameTF.text ?? ""
        if nickname == "" {
            let alert = UIAlertController(title: "OOPS", message: "Your name must contain characters.", preferredStyle: .alert)
            
            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let data: [String: Any] = [
            "nickname": nickname,
        ]
        
        let docRef = db.collection("user").document(uid)
        docRef.updateData(data) { error in
            if let err = error {
                print("Error update document: \(err)")
            } else {
                print("Update Successfully!!!")
                
                self.uploadMedia() { url in
                    guard let url = url else { return }
                }
                let avatar: UIImageView? = self.myAvatar
                if avatar != nil {
                    print("Change Avatar Successfully")
                    self.backToProfile()
                    
                } else {
                    let alert = UIAlertController(title: "Lỗi", message: "Chưa có ảnh avatar", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func sendingUpdate() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let update: String = "TRUE"
                
        // Lấy tham chiếu đến cơ sở dữ liệu
        let databaseRef = Database.database().reference().child("edit_profile")
        
        // Tạo một ID duy nhất cho thông điệp mới
        guard let messageId = databaseRef.childByAutoId().key else {
            return
        }
                
        // Tạo đối tượng message
        let message: [String: Any] = ["sender": uid,
                                      "update status": update,
                                      "MessageID": messageId,
                                      "timestamp": ServerValue.timestamp()]
        
        // Ghi thông điệp vào cơ sở dữ liệu tại vị trí mới
        databaseRef.child(messageId).setValue(message)
    }
    
    private func backToProfile() {
        let alert = UIAlertController(title: "YAY", message: "Successfully changed your nickname and avatar!", preferredStyle: .alert)
        
        let button = UIAlertAction(title: "OK", style: .cancel, handler: {(action:UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
            self.sendingUpdate()
        })

        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func uploadMedia(completion: @escaping (_ url: String?) -> Void) {
        showLoading(isShow: true, view: view)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        if let avatarImageData = self.myAvatar.image?.jpegData(compressionQuality: 0.8) {
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
                self.imagePicker.allowsEditing = false
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
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker.cameraCaptureMode = .photo
                    self.imagePicker.cameraDevice = .front
                    self.imagePicker.modalPresentationStyle = .fullScreen
                    self.present(self.imagePicker, animated: true,completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Thông báo", message: "Không tìm thấy máy ảnh", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
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
        case changeAvatarBt:
            print("Change Avatar!")
            
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
        
        case confirmBt:
            print("OKEOKE")
            updateProcess()
            
        default:
            break
        }
    }
    
}

extension EditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("error: \(info)")
            return
        }
        self.myAvatar.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
}
