//
//  NicknameVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 22/01/2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class NicknameVC: UIViewController {
    
    @IBOutlet weak var nicknameTF: UITextField!
    
    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    var getEmail: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(button: confirmBt, scrollView: scrollView, textField: nicknameTF)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nicknameTF.becomeFirstResponder()
    }
    
    func addDocFirestore() {
        let nickname = nicknameTF.text ?? ""
        let email = getEmail ?? ""
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        showLoading(isShow: true, view: view)
        
        db.collection("user").document(uid).setData([
            "email": email,
            "nickname": nickname,
            "uid": uid
          ]) { err in
              if let err = err {
                  print("Error Adding Doc: \(err)")
              } else {
                  print("Document added successfully!!!")
                  
                  showLoading(isShow: false, view: self.view)
                  
                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  
                  let avatarVC = storyboard.instantiateViewController(withIdentifier: "AvatarVC") as! AvatarVC
                  
                  self.navigationController?.pushViewController(avatarVC, animated: true)
                  
                  self.navigationController?.isNavigationBarHidden = true
              }
          }
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        
        switch sender {
        case confirmBt:
            addDocFirestore()
            
            print("Confirmed Nickname!")
            
        default:
            break
        }
    }
    
    @IBAction func handleNicknameTF(_ sender: UITextField) {
        print("value: \(sender.text ?? "")")
    }
}
