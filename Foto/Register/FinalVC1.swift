//
//  FinalVC1.swift
//  Foto
//
//  Created by Tran Thanh Trung on 02/03/2024.
//

import UIKit
import FirebaseFirestore

class FinalVC1: UIViewController {

    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var partnerName: UILabel!
    
    @IBOutlet weak var nextBt: UIButton!
    
    var getNickname: String?
    
    var getPartnerAvatar: UIImage?
    
    var selfDocID: String?
    
    var partnerID: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFinal(button: nextBt, border: avatarBorder, avatar: avatarImage)
        
        partnerName.text = getNickname
        avatarImage.image = getPartnerAvatar
    }
    
    private func updateData() {
        let docID = selfDocID ?? ""
        let partnerId = partnerID ?? ""
        let partnerName = getNickname ?? ""
        
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
