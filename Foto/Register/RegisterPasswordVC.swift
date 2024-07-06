//
//  RegisterPasswordVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 22/01/2024.
//

import UIKit
import FirebaseAuth

class RegisterPasswordVC: UIViewController {
    
    @IBOutlet weak var backBt: UIButton!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var nextBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    var receivedData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(button: nextBt, scrollView: scrollView, textField: passwordTF)
        
        print("Received Data: \(receivedData ?? "")")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passwordTF.becomeFirstResponder()
        
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        
        switch sender {
        case nextBt:
            print("NextTapped")
            handlePasswordRegister()
            
        case backBt:
            print("Back Tapped")
            backToEmailRes()
            
        default:
            break
        }
    }
    
    private func backToEmailRes() {
        let previousVC = (self.navigationController?.viewControllers[2])
        
        self.navigationController?.popToViewController(previousVC!, animated: true)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func handlePasswordRegister() {
        let email = receivedData
        let password = passwordTF.text ?? ""
        
        showLoading(isShow: true, view: view)
        
        if password.count < 6 {
            let alert = UIAlertController(title: "Lỗi", message: "Password phải từ 6 kí tự trở lên", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                showLoading(isShow: false, view: self.view)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        Auth.auth().createUser(withEmail: email ?? "", password: password) { [weak self] authResult, err in
            guard let self = self else { return }
                        
            /// success
            guard err == nil else {
                /// Cach xử lý custom error.
                var message = ""
                switch AuthErrorCode.Code(rawValue: err!._code) {
                case .emailAlreadyInUse:
                    message = "Email đã tồn tại"
                case .invalidEmail:
                    message = "Email không hợp lệ"
                default:
                    message = err?.localizedDescription ?? ""
                }
                
                /// Khi lỗi xảy ra thì show alert lỗi.
                let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                    self.backToEmailRes()
                }
                
                alert.addAction(okAction)
                
                showLoading(isShow: false, view: self.view)
                
                self.present(alert, animated: true)
                return
            }
            
            self.navigationController?.isNavigationBarHidden = true
        }
        
        showLoading(isShow: false, view: self.view)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nicknameVC = storyboard.instantiateViewController(withIdentifier: "NicknameVC") as! NicknameVC
        
        nicknameVC.getEmail = email
                
        self.navigationController?.pushViewController(nicknameVC, animated: true)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func handleTFChange(_ sender: UITextField) {
        print("value: \(sender.text ?? "")")
    }
    
}
