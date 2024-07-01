//
//  ProfileVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabase
import FirebaseCore

class ProfileVC: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var logOutBt: UIButton!
    
    @IBOutlet weak var optionView: UIView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var emailChangeBt: UIButton!
    
    @IBOutlet weak var passwordChangeBt: UIButton!
    
    @IBOutlet weak var anniChangeBt: UIButton!
    
    @IBOutlet weak var replaceBt: UIButton!
    
    @IBOutlet weak var partnerInfo: UIView!
    
    @IBOutlet weak var partnerAvatar: UIImageView!
    
    @IBOutlet weak var partnerName: UILabel!
    
    @IBOutlet weak var avatarBorder: UIView!
    
    @IBOutlet weak var myAvatar: UIImageView!
    
    @IBOutlet weak var myNickname: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        getPartnerInfo(name: partnerName, avatar: partnerAvatar, view: view)
        getMyInfo(name: myNickname, avatar: myAvatar, view: view)
        receivingUpdate()
    }
    
    private func setUpView() {
        optionView.layer.cornerRadius = 20
        optionView.layer.masksToBounds = false
        optionView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        optionView.layer.shadowOpacity = 0.25
        optionView.layer.shadowOffset = .zero
        optionView.layer.shadowRadius = 100
        
        logOutBt.layer.cornerRadius = logOutBt.frame.size.height/2
        logOutBt.layer.masksToBounds = false
        logOutBt.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        logOutBt.layer.shadowOpacity = 0.25
        logOutBt.layer.shadowOffset = .zero
        logOutBt.layer.shadowRadius = 100
        
        partnerAvatar.layer.cornerRadius = partnerAvatar.frame.size.height/2
        partnerAvatar.layer.borderWidth = 2
        partnerAvatar.layer.borderColor = #colorLiteral(red: 0.4453556538, green: 0.3677338362, blue: 0.9179279208, alpha: 1)
        
        self.navigationController?.isNavigationBarHidden = true
        
        partnerInfo.layer.cornerRadius = 20
        partnerInfo.layer.masksToBounds = false
        partnerInfo.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        partnerInfo.layer.shadowOpacity = 0.25
        partnerInfo.layer.shadowOffset = .zero
        partnerInfo.layer.shadowRadius = 100
        
        avatarBorder.layer.cornerRadius = avatarBorder.frame.size.height/2
        avatarBorder.layer.masksToBounds = false
        avatarBorder.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        avatarBorder.layer.shadowOpacity = 0.25
        avatarBorder.layer.shadowOffset = .zero
        avatarBorder.layer.shadowRadius = 100
        myAvatar.layer.cornerRadius = myAvatar.frame.size.height/2
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            routeToLoadingVC()
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: "Lỗi", message: signOutError.localizedDescription, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default)
            
            alert.addAction(okAction)
            
            present(alert, animated: true)
        }
    }
    
    private func routeToLoadingVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingViewController
        let navi = UINavigationController(rootViewController: loadingVC)
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = navi
    }
    
    private func receivingUpdate() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let databaseRef = Database.database().reference().child("edit_profile")

        databaseRef.observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? [String: Any] {
                let updateStatus = messageData["update status"] as? String ?? ""
                let sender = messageData["sender"] as? String ?? ""
                _ = messageData["MessageID"] as? String ?? ""
                _ = messageData["timestamp"] as? TimeInterval ?? 0
                
                if updateStatus == "TRUE" {
                    if sender == uid {
                        getMyInfo(name: self.myNickname, avatar: self.myAvatar, view: self.view)
                        self.updateForPartner()
                    } else {
                        getPartnerInfo(name: self.partnerName, avatar: self.partnerAvatar, view: self.view)
                    }
                }
            }
        })
    }
    
    private func updateForPartner() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }

        let docRef1 = db.collection("user").document(uid)
        docRef1.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error!!!")
                return
            }
            print(data)
            
            guard let partnerID = data["Partner's user ID"] as? String else {
                return
            }
            
            let nickname = self.myNickname.text ?? ""
            
            let partnerData: [String: Any] = [
                "Partner's nickname": nickname,
            ]
            
            let docRef2 = self.db.collection("user").document(partnerID)
            docRef2.updateData(partnerData) { error in
                if let err = error {
                    print("Error update document: \(err)")
                } else {
                    print("Update Successfully!!!")
                }
            }
        }
    }

    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case editButton:
            print("Edit Edit")
                        
            let editVC = EditVC()
            editVC.getCurrentName = myNickname.text
            editVC.getAvatar = myAvatar.image
            editVC.modalPresentationStyle = .popover
            editVC.popoverPresentationController?.sourceView = sender
            editVC.popoverPresentationController?.permittedArrowDirections = .up
            editVC.popoverPresentationController?.delegate = self
            self.present(editVC, animated: true, completion: nil)
            
        case emailChangeBt:
            print("Changing Email!")
            
            let emailVC = EmailVC()
            emailVC.modalPresentationStyle = .popover
            emailVC.popoverPresentationController?.sourceView = sender
            emailVC.popoverPresentationController?.permittedArrowDirections = .up
            emailVC.popoverPresentationController?.delegate = self
            self.present(emailVC, animated: true, completion: nil)
            
//            let alert = UIAlertController(title: "SORRY", message: "This function is still in progress.", preferredStyle: .alert)
//            
//            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            
//            alert.addAction(button)
//            self.present(alert, animated: true, completion: nil)
            
        case passwordChangeBt:
            print("Changing Password!")
            
//            let passwordVC = PasswordVC()
//            passwordVC.modalPresentationStyle = .popover
//            passwordVC.popoverPresentationController?.sourceView = sender
//            passwordVC.popoverPresentationController?.permittedArrowDirections = .up
//            passwordVC.popoverPresentationController?.delegate = self
//            self.present(passwordVC, animated: true, completion: nil)
            
            let alert = UIAlertController(title: "Sorry...", message: "This function is still in progress.", preferredStyle: .alert)
            
            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
            
        case anniChangeBt:
            print("Changing Anniversary!")
            
            let alert = UIAlertController(title: "Sorry...", message: "This function is still in progress.", preferredStyle: .alert)
            
            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
            
        case replaceBt:
            print("Changing Partner!")
            
            let alert = UIAlertController(title: "Sorry...", message: "This function is still in progress.", preferredStyle: .alert)
            
            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
            
        case logOutBt:
            print("Log Out Tapped!!!")
            
            let alert = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
                self.handleLogout()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(yesAction)
                        
            self.present(alert, animated: true)
        
        default:
            break
        }
    }
}
