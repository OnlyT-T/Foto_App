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

class FinalVC2: UIViewController {

    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var partnerNickname: UILabel!
    
    @IBOutlet weak var nextBt: UIButton!
    
    let db = Firestore.firestore()
    
    var getDocID: String?
    
    var getUserID: String?
        
    var selfDocID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFinal(button: nextBt, border: avatarBorder, avatar: avatarImage)
        getPartnerProfile()
    }
    
    func getPartnerProfile() {
        let userID = getUserID ?? ""
        let docID = getDocID ?? ""

        print("User ID: \(userID)")
        print("Firestore Document ID: \(docID)")
                
        let docRef = db.collection("user").document(docID)
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
        let docID = selfDocID ?? ""
        let partnerId = getUserID ?? ""
        let partnerName = partnerNickname.text ?? ""
        
        let data: [String: Any] = [
            "Partner's nickname": partnerName,
            "Partner's user ID": partnerId
        ]
        
        let docRef = db.collection("user").document(docID)
        docRef.updateData(data) { error in
            if let err = error {
                print("Error update document: \(err)")
            } else {
                print("Update Successfully!!!")
                self.routeToHomeVC()
            }
        }
    }
    
    private func routeToHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homeVC
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        print("Next Tap Tap")
        updateData()
    }

}
