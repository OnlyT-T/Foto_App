//
//  LoginPasswordVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/01/2024.
//

import UIKit
import PasswordTextField
import FirebaseAuth

class LoginPasswordVC: UIViewController {
    
    @IBOutlet weak var passwordTF: PasswordTextField!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var backBt: UIButton!
    
    @IBOutlet weak var nextBt: UIButton!
    
    var receivedEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(button: nextBt, scrollView: scrollView, textField: passwordTF)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        passwordTF.becomeFirstResponder()
    }
    
    private func handleLogin() {
        let email = receivedEmail ?? ""
        let password = passwordTF.text ?? ""
        
        showLoading(isShow: true, view: view)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                let alert = UIAlertController(title: "Lỗi", message: error?.localizedDescription, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default)
                
                alert.addAction(okAction)
                
                strongSelf.present(alert, animated: true)
                
                showLoading(isShow: false, view: self!.view)
                return
            }
            
            showLoading(isShow: false, view: self!.view)
            
            strongSelf.routeToMain()
        }
    }
    
    private func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homeVC
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case nextBt:
            print("Next Tapped")
            handleLogin()
            
        case backBt:
            print("Back Tapped")
            
            let previousVC = (self.navigationController?.viewControllers[2])
            
            self.navigationController?.popToViewController(previousVC!, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
        }
    }
}

