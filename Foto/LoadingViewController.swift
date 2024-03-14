//
//  LoadingViewController.swift
//  Foto
//
//  Created by Tran Thanh Trung on 16/01/2024.
//

import UIKit
import AMDots
import FirebaseAuth

class LoadingViewController: UIViewController {
    
    private var dotsView: AMDots!
    
    @IBOutlet weak var loadingView: UIView!
    
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showLoading(isShow: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             
             self.checkLogin()
         }
    }
    
    func showLoading(isShow: Bool) {
        
        dotsView = AMDots(frame: CGRect(x: 0, y: 0, width: 100, height: 50),
                              colors: [#colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1), #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1), #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1), #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1), #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)])
        dotsView.backgroundColor = .none
        dotsView.animationType = .scale
        dotsView.animationDuration = 0.5
        dotsView.aheadTime = 0.4
        loadingView.addSubview(dotsView)
        
        if isShow {
            dotsView.start()
        } else {
            dotsView.stop()
            dotsView.hidesWhenStopped = true
        }
    }
    
    private func checkLogin() {
        
        /// Check login
        if Auth.auth().currentUser != nil {
            /// Login rồi
            self.showLoading(isShow: false)
            routeToMain()
        } else {
            /// Chưa login
            self.showLoading(isShow: false)
            routeToWelcomeVC()
        }
    }
    
    private func routeToWelcomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeVC")
        
        self.navigationController?.pushViewController(welcomeVC, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        
        window?.makeKeyAndVisible()
    }
    
    private func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        
        self.navigationController?.pushViewController(homeVC, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        
        window?.makeKeyAndVisible()
    }
}
