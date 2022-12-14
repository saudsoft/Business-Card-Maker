//
//  BackgroundCardCollectionViewCell.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 01/07/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit

class BackgroundCardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardImage: UIImageView!
    
    var backgroundItem : UIImage! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        cardImage.image = backgroundItem
    }
}
