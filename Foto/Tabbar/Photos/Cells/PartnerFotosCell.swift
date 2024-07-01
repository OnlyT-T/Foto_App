//
//  PartnerFotosCell.swift
//  Foto
//
//  Created by Tran Thanh Trung on 26/06/2024.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseDatabaseInternal

class PartnerFotosCell: UICollectionViewCell {

    @IBOutlet weak var partnerNameLb: UILabel!
    
    @IBOutlet weak var captionLb: UILabel!
    
    @IBOutlet weak var fotoImage: UIImageView!
    
    @IBOutlet weak var dateLb: UILabel!
    
    @IBOutlet weak var interactBorder: UIView!
    
    @IBOutlet weak var interactImage: UIImageView!
    
    @IBOutlet weak var interactBt: UIButton!
    
    @IBOutlet weak var fotoView: UIView!
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var fotoIdLb: UILabel!
    
    var status: Bool = false
    
    let db = Firestore.firestore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUp()
    }
    
    private func setUp() {
        fotoView.layer.cornerRadius = 10
        fotoView.layer.masksToBounds = false
        
        fotoImage.layer.cornerRadius = 12
        fotoImage.layer.masksToBounds = true
        
        interactBt.layer.cornerRadius = interactBt.frame.size.height/2
        interactBorder.layer.cornerRadius = interactBorder.frame.size.height/2
    }
    
    private func updateStatus(status: Bool) {
        let fotoId = self.fotoIdLb.text ?? ""
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
            
            guard let conversationId = data["Conversation ID"] as? String else {
                return
            }
            
            let databaseRef = Database.database().reference().child("fotos").child(conversationId)
            
            if status {
                let message: [String: Any] = ["liked": "True"]
                
                databaseRef.child(fotoId).updateChildValues(message)
            } else {
                let message: [String: Any] = ["liked": "False"]
                
                databaseRef.child(fotoId).updateChildValues(message)
            }
        }
    }

    @IBAction func interactTapped(_ sender: UIButton) {
        print("Interaction Tapped")
        
        if status {
            status = false
            self.interactImage.image = UIImage(named: "Unlike")
            updateStatus(status: status)
        } else {
            status = true
            self.interactImage.image = UIImage(named: "Like")
            updateStatus(status: status)
        }
    }
}
