//
//  WelcomeVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 16/01/2024.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var loginBt: UIButton!
    
    @IBOutlet weak var signInBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpBt()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setUpBt() {
        loginBt.layer.cornerRadius = loginBt.frame.size.height/2
    }
    
    @IBAction func actionPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        switch sender {
        case loginBt:
            let emailVC = storyboard.instantiateViewController(withIdentifier: "LoginEmailVC") as! LoginEmailVC
            
            self.navigationController?.pushViewController(emailVC, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
        case signInBt:
            let emailVC = storyboard.instantiateViewController(withIdentifier: "RegisterEmailVC") as! RegisterEmailVC
            
            self.navigationController?.pushViewController(emailVC, animated: true)
            
            self.navigationController?.isNavigationBarHidden = true
            
        default:
            break
        }
    }
    
}
