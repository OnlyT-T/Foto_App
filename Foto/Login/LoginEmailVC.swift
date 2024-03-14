//
//  LoginEmailVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/01/2024.
//

import UIKit

class LoginEmailVC: UIViewController {

    @IBOutlet weak var backBt: UIButton!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var nextBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(button: nextBt, scrollView: scrollView, textField: emailTF)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emailTF.becomeFirstResponder()
    }
    
    private func handleEmailLogin() {
        let email = emailTF.text ?? ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let passwordVC = storyboard.instantiateViewController(withIdentifier: "LoginPasswordVC") as! LoginPasswordVC
        
        passwordVC.receivedEmail = email
        
        self.navigationController?.pushViewController(passwordVC, animated: true)
        
        self.navigationController?.isNavigationBarHidden = true

    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch sender {
        case nextBt:
            print("Next Tapped")
            handleEmailLogin()
            
        case backBt:
            print("Back Tapped")
            
            let previousVC = (self.navigationController?.viewControllers[1])
            
            self.navigationController?.popToViewController(previousVC!, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
        }
    }
    
}
