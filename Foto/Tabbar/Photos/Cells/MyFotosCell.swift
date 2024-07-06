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
        
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var dateLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setUp()
    }
    
    private func setUp() {
        fotoView.layer.cornerRadius = 10
        fotoView.layer.masksToBounds = false
        
        fotoImage.layer.cornerRadius = 12
        fotoImage.layer.masksToBounds = true
        
        interactBorder.layer.cornerRadius = interactBorder.frame.size.height/2
    }
}
