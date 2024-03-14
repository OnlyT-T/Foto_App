//
//  ConnectVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 27/02/2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class ConnectVC: UIViewController {
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var confirmBt: UIButton!
    
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var shareBt: UIButton!

    @IBOutlet weak var codeLb: UILabel!
    
    var getDocumentID: String?
    
    var sendingMessageID: String?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp(button: confirmBt, scrollView: scrollView, textField: codeTF)
        
        randomCode()
        receivingCode()
        listenToRes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        codeTF.becomeFirstResponder()
    }
    
    private func sendingCode() {
        
        let codeContent = codeTF.text ?? ""
        let documentID = getDocumentID ?? ""
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        showLoading(isShow: true, view: view)
        
        // Lấy tham chiếu đến cơ sở dữ liệu
        let databaseRef = Database.database().reference().child("messages")
        
        // Tạo một ID duy nhất cho thông điệp mới
        guard let messageId = databaseRef.childByAutoId().key else {
            return
        }
        
        sendingMessageID = messageId
        
        // Tạo đối tượng message
        let message: [String: Any] = ["content": codeContent,
                                      "sender": uid,
                                      "FirestoreDocumentID": documentID,
                                      "MessageID": messageId,
                                      "timestamp": ServerValue.timestamp()]
        
        // Ghi thông điệp vào cơ sở dữ liệu tại vị trí mới
        databaseRef.child(messageId).setValue(message)
    }
    
    private func getResFromConfirmVC() {
        let databaseRef = Database.database().reference().child("response_1")

        databaseRef.observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? [String: Any] {
                let content = messageData["content"] as? String ?? ""
                let sender = messageData["sender"] as? String ?? ""
                let timestamp = messageData["timestamp"] as? TimeInterval ?? 0
                
                self.timer?.invalidate()
                
                print("Succesfully received content: \(content)")
            }
        })
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            showLoading(isShow: false, view: self.view)
            
            let messageID = self.sendingMessageID ?? ""
            
            let alert = UIAlertController(title: "OOPS", message: "Can't find partner with the code you entered. Please enter another code.", preferredStyle: .alert)
            let button = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
            
            let ref = Database.database().reference().child("messages")

            ref.child(messageID).removeValue()
        }
    }
    
    private func receivingCode() {
        // Lấy tham chiếu đến cơ sở dữ liệu
        let databaseRef = Database.database().reference().child("messages")

        // Lắng nghe sự kiện thay đổi trên cơ sở dữ liệu
        databaseRef.observe(.childAdded, with: { (snapshot) in
            // Xử lý thông điệp mới được thêm vào cơ sở dữ liệu
            if let messageData = snapshot.value as? [String: Any] {
                let content = messageData["content"] as? String ?? ""
                let sender = messageData["sender"] as? String ?? ""
                let docID = messageData["FirestoreDocumentID"] as? String ?? ""
                let messageID = messageData["MessageID"] as? String ?? ""
                let timestamp = messageData["timestamp"] as? TimeInterval ?? 0
                
                // Hiển thị hoặc xử lý thông điệp
                if content == self.codeLb.text {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let confirmVC = storyboard.instantiateViewController(withIdentifier: "ConfirmVC") as! ConfirmVC
                    
                    confirmVC.senderID = sender
                    confirmVC.receivedDocID = docID                   
                    confirmVC.getMessageID = messageID
                    confirmVC.selfDocID = self.getDocumentID
                    
                    self.navigationController?.pushViewController(confirmVC, animated: true)
                    
                    self.navigationController?.isNavigationBarHidden = true
                } else {
                    print(snapshot)
                    print("Result Here")
                }
            }
        })
    }
    
    private func listenToRes() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ERROR: UID")
            return
        }
        
        let databaseRef = Database.database().reference().child("response_2")

        databaseRef.observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? [String: Any] {
                let content = messageData["content"] as? String ?? ""
                let sender = messageData["sender"] as? String ?? ""
                let messageID = messageData["messageID"] as? String ?? ""
                let docID = messageData["documentID"] as? String ?? ""
                let timestamp = messageData["timestamp"] as? TimeInterval ?? 0
                
                if content == "Yes to \(uid)" {
                    print("--> YES <--")
                    
                    showLoading(isShow: false, view: self.view)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let finalVC2 = storyboard.instantiateViewController(withIdentifier: "FinalVC2") as! FinalVC2
                    
                    finalVC2.getUserID = sender
                    finalVC2.getDocID = docID
                    finalVC2.selfDocID = self.getDocumentID
                    
                    self.navigationController?.pushViewController(finalVC2, animated: true)
                    
                    self.navigationController?.isNavigationBarHidden = true
                } else if content == "No to \(uid)" {
                    print("--> NO <--")
                    
                    showLoading(isShow: false, view: self.view)
                    
                    let ref = Database.database().reference().child("messages")

                    ref.child(messageID).removeValue()
                } else {
                    return
                }
            }
        })
    }
    
    private func randomCode() {
        let num1 = Int.random(in: 0 ..< 10)
        let num2 = Int.random(in: 0 ..< 10)
        let num3 = Int.random(in: 0 ..< 10)
        let num4 = Int.random(in: 0 ..< 10)
        
        print("CODE: \(num1)\(num2)\(num3)\(num4)")
        codeLb.text = "\(num1)\(num2)\(num3)\(num4)"
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        switch sender {
        case confirmBt:
            print("Confirm Tapped")
            
            sendingCode()
            getResFromConfirmVC()
            
        case shareBt:
            let shareText = codeLb.text ?? ""
            
            // standard activity view controller
            let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            
            self.present(vc, animated: true)
            print("Share Code!!!")
            
        default:
            break
        }
    }
    
    @IBAction func handleCodeTF(_ sender: UITextField) {
        print("value: \(sender.text ?? "")")
    }
    
}
