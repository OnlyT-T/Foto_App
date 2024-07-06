//
//  Fotos.swift
//  Foto
//
//  Created by Tran Thanh Trung on 23/06/2024.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabaseInternal
import FirebaseFirestore

final class Fotos {
    var id: String
    var image: String
    var caption: String
    var date: TimeInterval
    var fotoId: String
    var interact: String
    
    init(id: String, image: String, caption: String, date: TimeInterval, fotoId: String, interact: String) {
        self.id = id
        self.image = image
        self.caption = caption
        self.date = date
        self.fotoId = fotoId
        self.interact = interact
    }
}

extension Fotos {
    static func getData(completion: @escaping ([Fotos]) -> Void) {
        var fotos: [Fotos] = []
        let db = Firestore.firestore()
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("getData gets uid: \(uid)")
        
        let docRef = db.collection("user").document(uid)
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("ERROR")
                return
            }
            
            guard let conversationId = data["Conversation ID"] as? String else {
                print("Error getting conversation ID")
                return
            }
            
            let databaseRef = Database.database().reference().child("fotos").child(conversationId)
            
            databaseRef.observe(.childAdded, with: { (snapshot) in
                if let messageData = snapshot.value as? [String: Any] {
                    let senderId = messageData["sender id"] as? String ?? "No ID"
                    let caption = messageData["caption"] as? String ?? "No Caption"
                    let image = messageData["image name"] as? String ?? "No Image Name"
                    let time = messageData["time sent"] as? Date ?? Date(timeIntervalSince1970: 0)
                    let fotoId = messageData["foto id"] as? String ?? "No Foto ID"
                    let interact = messageData["liked"] as? String ?? ""
                    let timestamp = messageData["timestamp"] as? TimeInterval ?? 0
                    
                    let foto = Fotos(id: senderId, image: image, caption: caption, date: timestamp, fotoId: fotoId, interact: interact)
                    fotos.append(foto)
                }
                completion(fotos)
            }) { (error) in
                print("Failed to fetch data: \(error.localizedDescription)")
                completion(fotos)
            }
        }
    }
}
