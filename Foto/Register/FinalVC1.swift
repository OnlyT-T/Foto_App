//
//  FinalVC1.swift
//  Foto
//
//  Created by Tran Thanh Trung on 02/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseDatabaseInternal

class FinalVC1: UIViewController {

    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var partnerName: UILabel!
    
    @IBOutlet weak var nextBt: UIButton!
    
    var getNickname: String?
    
    var getPartnerAvatar: UIImage?
        
    var partnerID: String?
    
    var getConvoID: String?
    
    let db = Firestore.firestore()
    
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFinal(button: nextBt, border: avatarBorder, avatar: avatarImage)
        
        partnerName.text = getNickname
        avatarImage.image = getPartnerAvatar
    }
    
    private func updateData() {
        let partnerId = partnerID ?? ""
        let partnerName = getNickname ?? ""
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
                                      "timestamp": Date().timeIntervalSince1970]
        
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
            "Conversation ID": conversationId,
            "Anniversary": "01/01/2000"
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
        let previewVC = PreviewVC()
        let previewNavi = UINavigationController(rootViewController: previewVC)
        previewVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "Camera(Unselected)"), selectedImage: UIImage(named: "Camera(Selected)"))
        
        //Profile
        let profileVC = ProfileVC()
        let profileNavi = UINavigationController(rootViewController: profileVC)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile(Unselected)"), selectedImage: UIImage(named: "Profile(Selected)"))
        
        window?.makeKeyAndVisible()
        
        //tabbar controller
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [photosNavi, previewNavi, profileNavi]
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
