//
//  AnniVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 05/07/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreInternal

class AnniVC: UIViewController {

    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var cancelBt: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        contentView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 100
        
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case confirmBt:
            let selectedDate = datePicker.date
            let calendar = Calendar.current

            let day = calendar.component(.day, from: selectedDate)
            let month = calendar.component(.month, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let data: [String: Any] = [
                "Anniversary": "\(day)/\(month)/\(year)",
            ]
            
            let docRef1 = db.collection("user").document(uid)
            docRef1.updateData(data) { error in
                if let err = error {
                    print("Error update document: \(err)")
                } else {
                    print("Update Anni thành công!")
                }
            }
            
            docRef1.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    print("Error!!!")
                    return
                }
                
                guard let partnerID = data["Partner's user ID"] as? String else {
                    return
                }
                
                let docRef2 = self.db.collection("user").document(partnerID)
                
                docRef2.updateData(data) { error in
                    if let err = error {
                        print("Error update document: \(err)")
                    } else {
                        print("Update anniversary thành công!")
                        
                        let alert = UIAlertController(title: "Thông báo", message: "Cập nhật ngày kỉ niệm thành công!", preferredStyle: .alert)
                        
                        let button = UIAlertAction(title: "Xác nhận", style: .cancel, handler: {(action:UIAlertAction!) in
                            self.dismiss(animated: true, completion: nil)
                        })

                        alert.addAction(button)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        case cancelBt:
            print("Cancel")
            self.dismiss(animated: true, completion: nil)
            
        default:
            break
        }
    }
}
