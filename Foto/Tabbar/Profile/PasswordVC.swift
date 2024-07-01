//
//  PasswordVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 11/06/2024.
//

import UIKit
import PasswordTextField
import FirebaseAuth

class PasswordVC: UIViewController {
    
    @IBOutlet weak var firstPasswordTF: PasswordTextField!
    
    @IBOutlet weak var secondPasswordTF: PasswordTextField!
    
    @IBOutlet weak var firstPasswordBorder: UIView!
    
    @IBOutlet weak var secondPasswordBorder: UIView!

    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        firstPasswordTF.becomeFirstResponder()
    }
    
    private func setUp() {
        firstPasswordTF.layer.cornerRadius = 18.0
        firstPasswordBorder.layer.cornerRadius = 20.0
        
        secondPasswordTF.layer.cornerRadius = 18.0
        secondPasswordBorder.layer.cornerRadius = 20.0
        
        confirmBt.layer.cornerRadius = confirmBt.frame.size.height/2
        
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        print("Tap Tap Password")
    }
    
}
