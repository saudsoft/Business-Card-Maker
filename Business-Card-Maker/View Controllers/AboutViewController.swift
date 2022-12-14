//
//  AboutViewController.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 25/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController: UIViewController {
    @IBAction func facebook(_ sender: Any) {
        open(scheme: "https://www.facebook.com/saudsoft")
    }
    
    @IBAction func twitter(_ sender:Any) {
        open(scheme: "https://twitter.com/saudsoft")
    }
    
    @IBAction func website(_ sender: Any) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let url = URL(string: "https://saudsoft.com")
        let vc = SFSafariViewController(url: url!, configuration: config)
        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /// This func will try to open social app or if fail will open safari to website
    /// - parameters:
    ///   - scheme: The website URL for the social app
    ///
    /** Example Call:
     
     @IBAction func instagramClicked(_ sender: Any) {
     open(scheme: "http://www.instagram.com/profileName")
     }
     */
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
