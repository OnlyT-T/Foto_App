//
//  FinalVC2.swift
//  Foto
//
//  Created by Tran Thanh Trung on 11/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseDatabaseInternal

class FinalVC2: UIViewController {

    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var partnerNickname: UILabel!
    
    @IBOutlet weak var nextBt: UIButton!
    
    let db = Firestore.firestore()
    
    var window: UIWindow?
        
    var getUserID: String?
    
    var getConvoID: String?
            
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFinal(button: nextBt, border: avatarBorder, avatar: avatarImage)
        getPartnerProfile()
    }
    
    func getPartnerProfile() {
        let userID = getUserID ?? ""
        print("User ID: \(userID)")
                
        let docRef = db.collection("user").document(userID)
        docRef.getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error!!!")
                return
            }
            
            print(data)
            
            guard let nickname = data["nickname"] as? String else {
                return
            }

            self?.partnerNickname.text = nickname
        }

        let storage = Storage.storage()

        let storageRef = storage.reference().child("avatars").child("\(userID).jpg")

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        
                        self.avatarImage.image = image
                        
                        print("Set Avatar Successfully!!!")
                        
                    } else {
                        print("Failed to convert data to UIImage")
                    }
                } else {
                    print("No data returned from Firebase Storage")
                }
            }
        }

    }
    
    private func updateData() {
        let partnerId = getUserID ?? ""
        let partnerName = partnerNickname.text ?? ""
        let fotoCount: Int = 1
        let date = String(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        let conversationId = self.getConvoID ?? ""
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let databaseRef = Database.database().reference().child("fotos")
        
        guard let messageId = databaseRef.childByAutoId().key else {
            return
        }
        
        let message: [String: Any] = ["liked": "False",
                                      "sender id": uid,
                                      "caption": "Hello \(partnerName)",
                                      "image name": "WelcomeImage.jpg",
                                      "time sent": date,
                                      "foto id": messageId,
                                      "timestamp": ServerValue.timestamp()]
        
        databaseRef.child(conversationId).child(messageId).setValue(message)
        
        let imageName: String = "WelcomeImage.jpg"
        
        if let avatarImageData = UIImage(named: "WelcomeImage")!.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("library").child(uid).child(imageName)
            
            storageRef.putData(avatarImageData, metadata: nil) { metadata, error in
                guard let _ = metadata else {
                    print("Lỗi khi tải ảnh foto lên: \(error?.localizedDescription ?? "Lỗi không xác định")")
                    return
                }
                print("Upload Welcome Foto Successfully!")
            }
        } else {
            print("Lỗi: Không thể chuyển đổi ảnh avatar thành dữ liệu.")
        }
        
        let data: [String: Any] = [
            "Partner's nickname": partnerName,
            "Partner's user ID": partnerId,
            "My Fotos Count": fotoCount,
            "Conversation ID": conversationId
        ]
        
        let docRef = db.collection("user").document(uid)
        docRef.updateData(data) { error in
            if let err = error {
                print("Error update document: \(err)")
            } else {
                print("Update Successfully!!!")
                self.routeToTabbar()
            }
        }
    }
    
    private func routeToTabbar() {
        //Photos
        let photosVC = PhotosVC()
        let photosNavi = UINavigationController(rootViewController: photosVC)
        photosVC.tabBarItem = UITabBarItem(title: "Photos", image: UIImage(named: "Photos(Unselected)"), selectedImage: UIImage(named: "Photos(Selected)"))
        
        //Camera
        let cameraVC = CameraVC()
        let cameraNavi = UINavigationController(rootViewController: cameraVC)
        cameraVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "Camera(Unselected)"), selectedImage: UIImage(named: "Camera(Selected)"))
        
        //Profile
        let profileVC = ProfileVC()
        let profileNavi = UINavigationController(rootViewController: profileVC)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile(Unselected)"), selectedImage: UIImage(named: "Profile(Selected)"))
        
        window?.makeKeyAndVisible()
        
        //tabbar controller
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [photosNavi, cameraNavi, profileNavi]
        tabbarController.tabBar.tintColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        tabbarController.tabBar.backgroundColor = UIColor.white
        let lineView = UIView(frame: CGRect(x: 0, y: -16, width: tabbarController.tabBar.frame.size.width, height: 16))
        lineView.backgroundColor = UIColor.white
        tabbarController.tabBar.addSubview(lineView)
        
        self.navigationController?.pushViewController(tabbarController, animated: true)
        self.navigationController?.isNavigationBarHidden = true
                
        window?.rootViewController = tabbarController
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        print("Next Tap Tap")
        updateData()
    }

}
