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
    
    var window: UIWindow?

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
            
            strongSelf.routeToTabbar()
        }
    }
    
    private func routeToTabbar() {
        //Photos
        let photosVC = PhotosVC()
        let photosNavi = UINavigationController(rootViewController: photosVC)
        photosVC.tabBarItem = UITabBarItem(title: "Photos", image: UIImage(named: "Photos(Unselected)"), selectedImage: UIImage(named: "Photos(Selected)"))
        
        //Camera
        let cameraVC = CameraVC()
        let cameraNavi = UINavigationController(rootViewController: cameraVC)
        cameraVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "Camera(Unselected)"), selectedImage: UIImage(named: "Camera(Selected)"))
        
        //Profile
        let profileVC = ProfileVC()
        let profileNavi = UINavigationController(rootViewController: profileVC)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile(Unselected)"), selectedImage: UIImage(named: "Profile(Selected)"))
        
        window?.makeKeyAndVisible()
                
        //tabbar controller
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [photosNavi, cameraNavi, profileNavi]
        tabbarController.tabBar.tintColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        tabbarController.tabBar.backgroundColor = UIColor.white
        let lineView = UIView(frame: CGRect(x: 0, y: -16, width: tabbarController.tabBar.frame.size.width, height: 16))
        lineView.backgroundColor = UIColor.white
        tabbarController.tabBar.addSubview(lineView)
                
        self.navigationController?.pushViewController(tabbarController, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        
        window?.rootViewController = tabbarController
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

