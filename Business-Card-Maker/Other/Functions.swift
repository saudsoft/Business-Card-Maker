//
//  Functions.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 16/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import Foundation
import UIKit

func showAlert(withTitle title:String, andMessage message:String, inView sender:UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default, handler: nil))
    //    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    
    sender.present(alert, animated: true)
}
