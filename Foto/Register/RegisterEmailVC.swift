//
//  RegisterEmailVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 22/01/2024.
//

import UIKit
import FirebaseAuth

class RegisterEmailVC: UIViewController {

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
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case nextBt:
            print("Next Tapped")
            handleEmailRegister()
            
        case backBt:
            print("Back Tapped")
            
            let previousVC = (self.navigationController?.viewControllers[1])
            
            self.navigationController?.popToViewController(previousVC!, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
        }
    }
    
    func handleEmailRegister() {
        guard let email = emailTF.text else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let passwordVC = storyboard.instantiateViewController(withIdentifier: "RegisterPasswordVC") as! RegisterPasswordVC
        
        passwordVC.receivedData = email
        
        self.navigationController?.pushViewController(passwordVC, animated: true)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func handleTFChange(_ sender: UITextField) {
        print("value: \(sender.text ?? "")")
    }
}
