//
//  MyFotosCell.swift
//  Foto
//
//  Created by Tran Thanh Trung on 23/06/2024.
//

import UIKit

class MyFotosCell: UICollectionViewCell {

    @IBOutlet weak var fotoView: UIView!
    
    @IBOutlet weak var captionLb: UILabel!
    
    @IBOutlet weak var fotoImage: UIImageView!
    
    @IBOutlet weak var interactBorder: UIView!
    
    @IBOutlet weak var interactImage: UIImageView!
    
    @IBOutlet weak var interactBt: UIButton!
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var dateLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setUp()
    }
    
    private func setUp() {
        fotoView.layer.cornerRadius = 10
        fotoView.layer.masksToBounds = false
        fotoView.layer.shadowColor = #colorLiteral(red: 0.4432783723, green: 0.3698398471, blue: 0.9178406596, alpha: 1)
        fotoView.layer.shadowOpacity = 0.25
        fotoView.layer.shadowOffset = .zero
        fotoView.layer.shadowRadius = 100
        
        fotoImage.layer.cornerRadius = 12
        fotoImage.layer.masksToBounds = true
        
        interactBt.layer.cornerRadius = interactBt.frame.size.height/2
        interactBorder.layer.cornerRadius = interactBorder.frame.size.height/2
    }

    @IBAction func interactTapped(_ sender: UIButton) {
        print("Tap Tap")
    }
}
