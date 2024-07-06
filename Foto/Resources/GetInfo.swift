//
//  GetInfo.swift
//  Foto
//
//  Created by Tran Thanh Trung on 26/04/2024.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreInternal

public func getPartnerInfo(name: UILabel, avatar: UIImageView, view: UIView) {
    showLoading(isShow: true, view: view)
    
    let db = Firestore.firestore()

    guard let uid = Auth.auth().currentUser?.uid else {
        print("ERROR: UID")
        return
    }
    
    let docRef = db.collection("user").document(uid)
    docRef.getDocument { snapshot, error in
        guard let data = snapshot?.data(), error == nil else {
            print("Error!!!")
            return
        }
        
        print(data)
        
        guard let nickname = data["Partner's nickname"] as? String else {
            return
        }
        
        guard let partnerID = data["Partner's user ID"] as? String else {
            return
        }

        name.text = nickname
        
        let storage = Storage.storage()

        let storageRef = storage.reference().child("avatars").child("\(partnerID).jpg")

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        
                        avatar.image = image
                        
                        print("Set Avatar Successfully!!!")
                        
                    } else {
                        print("Failed to convert data to UIImage")
                    }
                } else {
                    print("No data returned from Firebase Storage")
                }
            }
        }
    }
    
    showLoading(isShow: false, view: view)
}


public func getMyInfo(name: UILabel, avatar: UIImageView, view: UIView) {
    showLoading(isShow: true, view: view)
    
    let db = Firestore.firestore()

    guard let uid = Auth.auth().currentUser?.uid else {
        print("ERROR: UID")
        return
    }
    
    let docRef = db.collection("user").document(uid)
    docRef.getDocument { snapshot, error in
        guard let data = snapshot?.data(), error == nil else {
            print("Error!!!")
            return
        }
        
        print(data)
        
        guard let nickname = data["nickname"] as? String else {
            return
        }

        name.text = nickname
        
        let storage = Storage.storage()

        let storageRef = storage.reference().child("avatars").child("\(uid).jpg")

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        
                        avatar.image = image
                        
                        print("Set Avatar Successfully!!!")
                        
                    } else {
                        print("Failed to convert data to UIImage")
                    }
                } else {
                    print("No data returned from Firebase Storage")
                }
            }
        }
    }
    
    showLoading(isShow: false, view: view)
}

public func getConvoID(id: UILabel) {
    let db = Firestore.firestore()
    
    guard let uid = Auth.auth().currentUser?.uid else {
        print("ERROR UID")
        return
    }
    
    let docRef = db.collection("user").document(uid)
    docRef.getDocument { snapshot, error in
        guard let data = snapshot?.data(), error == nil else {
            print("Error Data")
            return
        }
        
        guard let convoId = data["Conversation ID"] as? String else {
            print("ERROR Conversation ID")
            return
        }
        
        id.text = convoId
    }
}

public func getAnniDate(date: UILabel) {
    let db = Firestore.firestore()
    
    guard let uid = Auth.auth().currentUser?.uid else {
        print("ERROR UID")
        return
    }
    
    let docRef = db.collection("user").document(uid)
    docRef.getDocument { snapshot, error in
        guard let data = snapshot?.data(), error == nil else {
            print("Error Data")
            return
        }
        
        guard let anniDate = data["Anniversary"] as? String else {
            print("ERROR Anni")
            return
        }
        
        date.text = "Anniversary: \(anniDate)"
    }
}
