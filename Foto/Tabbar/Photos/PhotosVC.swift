//
//  PhotosVC.swift
//  Foto
//
//  Created by Tran Thanh Trung on 19/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreInternal
import FirebaseDatabaseInternal

class PhotosVC: UIViewController {

    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var avatarView: UIView!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var partnerName: UILabel!
    
    @IBOutlet weak var anniversaryDate: UILabel!
    
    @IBOutlet weak var fotosLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var convoIdLb: UILabel!
        
    let db = Firestore.firestore()
    
    var fotos: [Fotos] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        getPartnerInfo(name: partnerName, avatar: avatarImage, view: view)
        getConvoID(id: convoIdLb)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let myNib = UINib(nibName: "MyFotosCell", bundle: .main)
        collectionView.register(myNib, forCellWithReuseIdentifier: "My Cell")
        let partnerNib = UINib(nibName: "PartnerFotosCell", bundle: .main)
        collectionView.register(partnerNib, forCellWithReuseIdentifier: "Partner Cell")
        
        fetchData()
        setLayout()
    }
    
    private func fetchData() {
        Fotos.getData { [weak self] fetchedFotos in
            self?.fotos = fetchedFotos
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func setLayout() {
        //1
        let screenWidth = UIScreen.main.bounds.width - 10
        //2
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth, height: 280)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        //3
        collectionView!.collectionViewLayout = layout
    }

    private func setUp() {
        // Set shadow for the top view
        infoView.layer.masksToBounds = true
        infoView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        infoView.layer.shadowOpacity = 0.25
        infoView.layer.shadowOffset = .zero
        infoView.layer.shadowRadius = 100
        
        // Set circular border for avatar
        avatarView.layer.cornerRadius = avatarView.frame.size.height/2
        avatarImage.layer.cornerRadius = avatarImage.frame.size.height/2
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = #colorLiteral(red: 0.4453556538, green: 0.3677338362, blue: 0.9179279208, alpha: 0.5035613609)
    }
}

extension PhotosVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let latestFotosCount: Int = fotos.count
        self.fotosLb.text = "\(latestFotosCount) SHARED FOTOS"
        return fotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "My Cell", for: indexPath) as! MyFotosCell
        let partnerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Partner Cell", for: indexPath) as! PartnerFotosCell
        
        let foto = fotos[indexPath.item]
        let uid = Auth.auth().currentUser?.uid ?? ""

        if foto.id == uid {
            myCell.captionLb.text = foto.caption
            myCell.dateLb.text = foto.date
            if foto.interact == "True" {
                print("Get Liked")
                myCell.interactImage.image = UIImage(named: "Like")
            } else if foto.interact == "False" {
                print("Get Unliked")
                myCell.interactImage.image = UIImage(named: "Unlike")
            } else {
                print("Error interaction")
            }
            
            let storage = Storage.storage()
            
            let storageRef = storage.reference().child("library").child(foto.id).child(foto.image)
            
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            
                            myCell.fotoImage.image = image
                            
                            print("Set Image Successfully!!!")
                            
                        } else {
                            print("Failed to convert data to UIImage")
                        }
                    } else {
                        print("No data returned from Firebase Storage")
                    }
                }
            }
            return myCell
            
        } else {
            print("Not My Cell")
            
            partnerCell.captionLb.text = foto.caption
            partnerCell.dateLb.text = foto.date
            partnerCell.partnerNameLb.text = self.partnerName.text
            partnerCell.fotoIdLb.text = foto.fotoId
            
            if foto.interact == "True" {
                print("Liked")
                partnerCell.interactImage.image = UIImage(named: "Like")
                partnerCell.status = true
            } else if foto.interact == "False" {
                print("Unlike")
                partnerCell.interactImage.image = UIImage(named: "Unlike")
                partnerCell.status = false
            } else {
                print("Error interaction")
            }
            
            let storage = Storage.storage()
            
            let storageRef = storage.reference().child("library").child(foto.id).child(foto.image)
            
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                } else {
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            
                            partnerCell.fotoImage.image = image
                            
                            print("Set Image Successfully!!!")
                            
                        } else {
                            print("Failed to convert data to UIImage")
                        }
                    } else {
                        print("No data returned from Firebase Storage")
                    }
                }
            }
            return partnerCell
        }
    }
}
