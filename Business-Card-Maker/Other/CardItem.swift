//
//  CardItem.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 18/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import CoreData

class CardItem {
    var cardTitle = ""
    var cardImage: UIImage
    
    init() {
        self.cardTitle = ""
        self.cardImage = UIImage()
    }
    
    init(cardTitle:String, cardImage:UIImage) {
        self.cardTitle = cardTitle
        self.cardImage = cardImage
    }
    
    static func fetchVCards(vCards: [NSManagedObject]) -> [CardItem] {
        var cardItems: [CardItem] = [CardItem]()
        
        var i = 0
        if vCards.count > 0 {
            for item in vCards {
                let number = Int.random(in: 0 ... 9)
//                if i < 10 {
                cardItems.append(CardItem(cardTitle: item.value(forKey: vcTitles.cardTitle) as! String, cardImage: UIImage(named: "Card\(number)")!))
                    i += 1

            }
        } else {
            let number = Int.random(in: 0 ... 9)
            cardItems.append(CardItem(cardTitle: NSLocalizedString("noCards", comment: "No Cards!"), cardImage: UIImage(named: "Card\(number)")!))
        }
        return cardItems
    }
}
