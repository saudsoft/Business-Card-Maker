//
//  CardItemCollectionViewCell.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 18/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//


import UIKit
import CoreData

class CardItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardTitleLabel: UILabel!
    
    @IBOutlet weak var cardDeleteButton:UIButton!
    
    @IBAction func cardDeleteTapped(_ sender: Any) {
        print("DELETE ITEM")
    }
    
    var cardItem : CardItem! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI() {
        if let cardItem = cardItem {
            cardImageView.image = cardItem.cardImage
            cardTitleLabel.text = cardItem.cardTitle
        } else {
            cardTitleLabel.text = nil
            cardImageView.image = nil
        }
    }
    
    func deleteObject(vCard: NSManagedObject) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        managedContext.delete(vCard)
        
        do {
            try managedContext.save()
//            loadData()
        } catch {
            print("ERROR DELETEING")
        }
        
        print("Card Deleted!")
        
    }
}
