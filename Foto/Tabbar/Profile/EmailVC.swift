//
//  EmailVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 11/06/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreInternalWrapper

class EmailVC: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var emailBorder: UIView!
    
    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    let db = Firestore.firestore()
    
    var currentUser: User? {
       return Auth.auth().currentUser
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        setCurrentEmail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTF.becomeFirstResponder()
    }
    
    private func setCurrentEmail() {
        guard let myEmail = Auth.auth().currentUser?.email else {
            print("ERROR: UID")
            return
        }
        emailTF.text = myEmail
    }
    
    private func setUp() {
        emailTF.layer.cornerRadius = 18.0
        emailBorder.layer.cornerRadius = 20.0
        
        confirmBt.layer.cornerRadius = confirmBt.frame.size.height/2
        
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    private func sendingUpdate(email: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let data: [String: Any] = [
            "email": email,
        ]
        
        let docRef = db.collection("user").document(uid)
        docRef.updateData(data) { error in
            if let err = error {
                print("Error update document: \(err)")
            } else {
                print("Update Successfully!!!")
            }
        }
    }
    
    private func updateUserEmail(newEmail: String, password: String) {
        let emailVC = EmailVC()
        
        // 1. Get the credential
        guard let currentEmail = currentUser?.email else {return}
        var credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)
        
        print("---> \(credential)")
        
        self.currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if error != nil {
                print("ERROR: ", error?.localizedDescription ?? "")
                return
            }
            
            //3. Update email
            self.currentUser?.updateEmail(to: newEmail, completion: { (error) in
                let emailVC = EmailVC()
                
                if error == nil {
                    let alert = UIAlertController(title: "Thông báo", message: "Cập nhật email thành công!", preferredStyle: .alert)
                    
                    let button = UIAlertAction(title: "Xác nhận", style: .cancel, handler: {(action:UIAlertAction!) in
                        self.dismiss(animated: true, completion: nil)
                        self.sendingUpdate(email: newEmail)
                    })
                    alert.addAction(button)
                    
                    emailVC.present(alert, animated: true)
                    
                } else {
                    var message = ""
                    switch AuthErrorCode.Code(rawValue: error!._code) {
                    case .emailAlreadyInUse:
                        message = "Email đã tồn tại"
                    case .invalidEmail:
                        message = "Email không hợp lệ"
                    default:
                        message = error?.localizedDescription ?? ""
                    }
                    
                    let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true)
                    return
                }
            })
        })
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        print("Tap Tap Email")
//        let newEmail = self.emailTF.text ?? ""
//        
//        let alertController = UIAlertController(title: "Password Required", message: "You need to enter your password before changing your email.", preferredStyle: UIAlertController.Style.alert)
//        alertController.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "Password"
//        }
//        let saveAction = UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { alert -> Void in
//            let textField = alertController.textFields![0] as UITextField
//            let enteredPW = textField.text ?? ""
//            
//            self.updateUserEmail(newEmail: newEmail, password: enteredPW)
//        })
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
//            (action : UIAlertAction!) -> Void in })
//        
//        alertController.addAction(saveAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
        
        let alert = UIAlertController(title: "Thông báo", message: "Tính năng đang được phát triển. Xin vui lòng thử lại sau.", preferredStyle: .alert)
        
        let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
}
