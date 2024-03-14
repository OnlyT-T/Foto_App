//
//  HomeVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 12/03/2024.
//

import UIKit
import FirebaseAuth

class HomeVC: UIViewController {

    @IBOutlet weak var logOutBt: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            routeToLoadingVC()
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: "Lỗi", message: signOutError.localizedDescription, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default)
            
            alert.addAction(okAction)
            
            present(alert, animated: true)
        }
    }
    
    private func routeToLoadingVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "LoadingVC") as! LoadingViewController
        let navi = UINavigationController(rootViewController: loadingVC)
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = navi
    }

    @IBAction func buttonTapped(_ sender: Any) {
        print("Log Out Tapped")
        handleLogout()
    }
    
}
