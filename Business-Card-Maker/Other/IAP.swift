//
//  IAP.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 01/07/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import Foundation
import IAPurchaseManager


func purchaseProduct(productID: String, sender:UIViewController) {
//    HUD.show(.progress)
    if IAPManager.shared.canMakePayments() {
        print("CanMakePayments")
        IAPManager.shared.purchaseProductWithId(productId: productID) { (error) in
            
            if error == nil {
//                HUD.hide()
                // successful purchase!
                UserDefaults.standard.set(true, forKey: UserDefaults.keys.premiumCustomer)
                UserDefaults.standard.set(true, forKey: productID)
                showAlert(withTitle: "appName", andMessage: NSLocalizedString("successLinkatyPlusPurchase", comment: "تم شراء \"لنكاتي - بلس\" بنجاح."), inView: sender)
                print("successful purchase!")
            } else {
//                HUD.hide()
                UserDefaults.standard.set(false, forKey: UserDefaults.keys.premiumCustomer)
                UserDefaults.standard.set(false, forKey: productID)
                print("something wrong..")
                showAlert(withTitle: "appName", andMessage: NSLocalizedString("errorPurchaseLinkatyPlus", comment: "حدث خطأ أثناء معالجة الشراء، يرجى المحاولة مرة أخرى"), inView: sender)
                print(error?.localizedDescription as Any)
            }
        }
    } else {
        showAlert(withTitle: NSLocalizedString("error", comment: "خطأ"), andMessage: NSLocalizedString("errorAppStoreConnection", comment: "غير قادر على الاتصال بمتجر التطبيقات، يرجى المحاولة مرة أخرى والتحقق من اتصال الإنترنت"), inView: sender)
    }
}


func isPremiumCustomer() -> Bool {
    let isPremiumCustomer:Bool = UserDefaults.standard.bool(forKey: UserDefaults.keys.premiumCustomer)
    print("USER IS \(isPremiumCustomer)")
    return isPremiumCustomer
}
