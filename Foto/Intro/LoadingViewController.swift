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
            routeToTabbar()
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
        
        window?.rootViewController = welcomeVC
        window?.makeKeyAndVisible()
    }
    
    private func routeToTabbar() {
        //Photos
        let photosVC = PhotosVC()
        let photosNavi = UINavigationController(rootViewController: photosVC)
        photosVC.tabBarItem = UITabBarItem(title: "Fotos", image: UIImage(named: "Photos(Unselected)"), selectedImage: UIImage(named: "Photos(Selected)"))
        
        //Camera
        let previewVC = PreviewVC()
        let previewNavi = UINavigationController(rootViewController: previewVC)
        previewVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(named: "Camera(Unselected)"), selectedImage: UIImage(named: "Camera(Selected)"))
        
        //Profile
        let profileVC = ProfileVC()
        let profileNavi = UINavigationController(rootViewController: profileVC)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "Profile(Unselected)"), selectedImage: UIImage(named: "Profile(Selected)"))
        
        window?.makeKeyAndVisible()
        
        //tabbar controller
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [photosNavi, previewNavi, profileNavi]
        tabbarController.tabBar.tintColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        tabbarController.tabBar.backgroundColor = UIColor.white
        let lineView = UIView(frame: CGRect(x: 0, y: -16, width: tabbarController.tabBar.frame.size.width, height: 16))
        lineView.backgroundColor = UIColor.white
        tabbarController.tabBar.addSubview(lineView)
        
        self.navigationController?.pushViewController(tabbarController, animated: true)
        self.navigationController?.isNavigationBarHidden = true
                
        window?.rootViewController = tabbarController
    }
}
