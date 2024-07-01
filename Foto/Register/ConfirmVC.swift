//
//  ConfirmVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 27/02/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestoreInternal
import FirebaseDatabaseInternal

class ConfirmVC: UIViewController {
    
    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var disallowBt: UIButton!
    
    @IBOutlet weak var allowBt: UIButton!
    
    @IBOutlet weak var partnerNameLb: UILabel!
    
    @IBOutlet weak var partnerAvatar: UIImageView!
    
    let db = Firestore.firestore()
    
    var senderID: String?
    
    var receivedMyCode: String?
    
    var getMessageID: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpConfirm(button1: disallowBt, button2: allowBt, border: avatarBorder, avatar: partnerAvatar)
        
        getPartnerProfile()
        
        // Tự động gửi tín hiệu về cho thiết bị gửi code
        sendingRes()
    }
    
    private func sendingRes() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let userID = senderID ?? ""
        
        let myCode = receivedMyCode ?? ""
        
        let databaseRef = Database.database().reference().child("response_1")
        
        guard let messageId = databaseRef.childByAutoId().key else {
            return
        }
        
        let message: [String: Any] = ["content": "Have received code from \(userID)",
                                      "sender": uid,
                                      "timestamp": ServerValue.timestamp()]
        
        databaseRef.child(myCode).child(messageId).setValue(message)
    }
    
    func getPartnerProfile() {
        let userID = senderID ?? ""
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

            self?.partnerNameLb.text = nickname
        }

        let storage = Storage.storage()

        let storageRef = storage.reference().child("avatars").child("\(userID).jpg")

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        
                        self.partnerAvatar.image = image
                        
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
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case disallowBt:
            print("Not My Partner!!")
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("ERROR: UID")
                return
            }
            let messID = getMessageID ?? ""
            let userID = senderID ?? ""
            
            showLoading(isShow: true, view: view)
            
            let databaseRef = Database.database().reference().child("response_2")
            
            guard let messageId = databaseRef.childByAutoId().key else {
                return
            }
            
            let message: [String: Any] = ["content": "No to \(userID)",
                                          "sender": uid,
                                          "messageID": messID,
                                          "timestamp": ServerValue.timestamp()]
            
            databaseRef.child(messageId).setValue(message)
            
            showLoading(isShow: false, view: view)
            
            let previousVC = (self.navigationController?.viewControllers[6])
            
            self.navigationController?.popToViewController(previousVC!, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        case allowBt:
            print("Confirm Partner!!")
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("ERROR: UID")
                return
            }
            
            showLoading(isShow: true, view: view)

            let userID = senderID ?? ""
            
            let databaseRef1 = Database.database().reference().child("response_2")
            
            guard let messageId = databaseRef1.childByAutoId().key else {
                return
            }
            
            let databaseRef2 = Database.database().reference().child("fotos")

            guard let conversationId = databaseRef2.childByAutoId().key else {
                return
            }
            
            let message: [String: Any] = ["content": "Yes to \(userID)",
                                          "sender": uid,
                                          "messageID": messageId,
                                          "conversationID": conversationId,
                                          "timestamp": ServerValue.timestamp()]
            
            databaseRef1.child(messageId).setValue(message)
            
            showLoading(isShow: false, view: view)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let finalVC1 = storyboard.instantiateViewController(withIdentifier: "FinalVC1") as! FinalVC1
            
            finalVC1.getNickname = partnerNameLb.text
            finalVC1.getPartnerAvatar = partnerAvatar.image
            finalVC1.partnerID = userID
            finalVC1.getConvoID = conversationId
            
            self.navigationController?.pushViewController(finalVC1, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
        }
    }
    
}
