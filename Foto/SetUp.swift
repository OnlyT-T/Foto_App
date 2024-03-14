//
//  SetUp.swift
//  Foto
//
//  Created by Tran Thanh Trung on 22/01/2024.
//

import Foundation
import UIKit
import MBProgressHUD

public func setUp(button: UIButton, scrollView: UIScrollView, textField: UITextField) {
    // Set up rounded corner for button
    button.layer.cornerRadius = button.frame.size.height/2
    
    // Set up for Scroll View
    scrollView.isScrollEnabled = false
    scrollView.showsHorizontalScrollIndicator = false
    
    // Set up for Text Field
    textField.layer.cornerRadius = 18.0
}

public func setUpAvatar(button: UIButton, scrollView: UIScrollView, avatar: UIImageView, avatarBorder: UIView) {
    // Set up rounded corner for button
    button.layer.cornerRadius = button.frame.size.height/2
    
    // Set up for Scroll View
    scrollView.isScrollEnabled = false
    scrollView.showsHorizontalScrollIndicator = false
    
    // Set up for Avatar
    avatar.layer.cornerRadius = 10
    avatarBorder.layer.cornerRadius = 12
}

public func setUpConfirm(button1: UIButton, button2: UIButton, border: UIView, avatar: UIImageView) {
    // Set up rounded corner for button
    button1.layer.cornerRadius = button1.frame.size.height/2
    
    // Set up rounded corner for button
    button2.layer.cornerRadius = button2.frame.size.height/2
    
    // Set up for Avatar
    avatar.layer.cornerRadius = 15
    border.layer.cornerRadius = 20
}

public func setUpFinal(button: UIButton, border: UIView, avatar: UIImageView) {
    // Set up rounded corner for button
    button.layer.cornerRadius = button.frame.size.height/2
    
    // Set up for Avatar
    avatar.layer.cornerRadius = 15
    border.layer.cornerRadius = 20
}

public func showLoading(isShow: Bool, view: UIView) {
    
    if isShow {
        MBProgressHUD.showAdded(to: view, animated: true)
    } else {
        MBProgressHUD.hide(for: view, animated: true)
    }
}
