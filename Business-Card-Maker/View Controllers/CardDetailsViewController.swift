//
//  CardDetailsViewController.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 16/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import PhoneNumberKit
import CoreData
import Contacts

class CardDetailsViewController: UIViewController {
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var mobileNumber: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var webAddress: UILabel!
    @IBOutlet weak var faxNumber: UILabel!
    @IBOutlet weak var jobTitle: UILabel!
    @IBOutlet weak var orgName: UILabel!
    @IBOutlet weak var seperator: UILabel!
    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var fullCardView:UIView!
    @IBOutlet weak var cardBGImageView: UIImageView!
    
    var cardBGImage: String = "Card4" {
        didSet {
            UserDefaults.standard.set(cardBGImage, forKey: UserDefaults.keys.cardBGImage)

            self.changeCardBG()
            print("DidChagne ***********")
        }
    }
    
    var isRTL = false
    var vCard: NSManagedObject? {
        didSet {
            cnContact = cnContact.vCardToCNContact(vCard: vCard!)
        }
    }
    
    var cnContact = SSCContact()
    
    var selectedItemIndex :Int = 0
    
    @IBAction func deleteVCard(_ sender:Any) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        guard let vC = vCard else {
            print("Exit guard statment")
            return
        }
        managedContext.delete(vC)
        
        do {
            try managedContext.save()
        } catch {
            print("ERROR DELETEING")
        }
        
        print("Card Deleted!")
        dismissView()
    }
    
    func dismissView() {
        
        self.navigationController?.popViewController(animated: true)
//        if let navController = presentingViewController as? UINavigationController {
//            let presenter = navController.topViewController as! CardsViewController
//            presenter.loadData()
//        }
    }
    
    @IBAction func showActionSheet(_ sender: Any) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Share Option", preferredStyle: .actionSheet)
        
        // 2
        let shareQRImage = UIAlertAction(title: "Share QR Image", style: .default, handler: ({ (_) in
            self.shareQRImage()
            print("Share QR Image")
        }))
        
        let shareVCardContact = UIAlertAction(title: "Share VCard Contact", style: .default, handler: ({ (_) in
            self.shareVCard()
            print("Share VCard Contact")
        }))
        
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // 4
        optionMenu.addAction(shareQRImage)
        optionMenu.addAction(shareVCardContact)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func changeCardBG() {
        
        cardBGImageView.image = UIImage(named: cardBGImage)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let cbg = UserDefaults.standard.string(forKey: UserDefaults.keys.cardBGImage) {
            cardBGImage = cbg
        }
        changeCardBG()
        
        if self.view.semanticContentAttribute == .forceRightToLeft {
            isRTL = true
        } else {
            isRTL = false
        }

        self.fullName.text = ""
        self.faxNumber.text = ""
        self.jobTitle.text = ""
        self.orgName.text = ""
        self.emailAddress.text = ""
        self.webAddress.text = ""
        self.mobileNumber.text = ""
        self.seperator.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cnContact.cardTitle == "" {
            self.title = NSLocalizedString("noTitle", comment: "No Title!")
        } else {
            self.title = cnContact.cardTitle
        }
        let fullName = "\(self.cnContact.givenName) \(self.cnContact.middleName) \(self.cnContact.familyName)"
        let temp = fullName.removeWhitespace()
        DispatchQueue.main.async {
            self.fullName.text = temp.removeWhitespace()
            self.faxNumber.text = self.cnContact.faxNumber
            self.jobTitle.text = self.cnContact.jobTitle
            self.orgName.text = self.cnContact.orgnizationName
            self.emailAddress.text = self.cnContact.emailAddress
            self.webAddress.text = self.cnContact.websiteURL
            self.mobileNumber.text = self.cnContact.mobileNumber
            self.qrcodeImage.image = self.cnContact.makeQRCode()
            if self.cnContact.faxNumber != "" && self.cnContact.mobileNumber != "" {
                self.seperator.text = "|"
            } else {
                self.seperator.text = ""
            }
            
            if fullName.isArabic {
                self.isRTL = true
                self.changeDirection()
            } else {
                self.isRTL = false
                self.changeDirection()
            }
        }
    }
    
    @IBAction func saveCardView(_ sender: Any) {
        let cardImage: UIImage = self.fullCardView.asImage()
        UIImageWriteToSavedPhotosAlbum(cardImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func changeFieldDir() {
        changeDirection()
    }
    
    func shareVCard() {
        print("Share VCard")
        let contact = cnContact.getContact()
        let cacheDirectory = try! FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        
        let fileLocation = cacheDirectory.appendingPathComponent("\(CNContactFormatter().string(from: contact)!).vcf")
        
        let contactData = try! CNContactVCardSerialization.data(with: [contact])
        do {
            _ = try contactData.write(to: fileLocation, options: .atomic)
        } catch let error {
            print(error)
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileLocation], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    func shareQRImage() {
        print("Share QR Image")
        showActivityController()
    }
    
    func showActivityController() {
        
        if let image = qrcodeImage.image {
            let ciImage = image.ciImage
            let context = CIContext()
            let cgImage = context.createCGImage(ciImage!, from: ciImage!.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            
            let imageToShare = [uiImage]
            
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            
            activityViewController.completionWithItemsHandler = { (activity: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                
                if completed {
                    //                    print(activity?.rawValue)
                    if activity?.rawValue == "com.apple.UIKit.activity.SaveToCameraRoll" {
                        let ac = UIAlertController(title: NSLocalizedString("saved", comment: "Saved!"), message: NSLocalizedString("qrSaved", comment: "Your QR image has been saved to your photos."), preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Ok"), style: .default))
                        self.present(ac, animated: true)
                    }
                    print("Completed")
                }
                UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            }
            present(activityViewController, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: NSLocalizedString("saveImageError", comment: "Save error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Ok"), style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: NSLocalizedString("saved", comment: "Saved!"), message: NSLocalizedString("cardImageSaved", comment: "Your card image has been saved to your photos."), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Ok"), style: .default))
            present(ac, animated: true)
        }
    }
    
    func changeDirection() {
        
        if isRTL {
            self.fullCardView.semanticContentAttribute = .forceRightToLeft
            self.fullName.semanticContentAttribute = .forceRightToLeft
            self.faxNumber.semanticContentAttribute = .forceRightToLeft
            self.jobTitle.semanticContentAttribute = .forceRightToLeft
            self.orgName.semanticContentAttribute = .forceRightToLeft
            self.emailAddress.semanticContentAttribute = .forceRightToLeft
            self.webAddress.semanticContentAttribute = .forceRightToLeft
            self.mobileNumber.semanticContentAttribute = .forceRightToLeft
            self.seperator.semanticContentAttribute = .forceRightToLeft
        } else {
            self.fullCardView.semanticContentAttribute = .forceLeftToRight
            self.fullName.semanticContentAttribute = .forceLeftToRight
            self.faxNumber.semanticContentAttribute = .forceLeftToRight
            self.jobTitle.semanticContentAttribute = .forceLeftToRight
            self.orgName.semanticContentAttribute = .forceLeftToRight
            self.emailAddress.semanticContentAttribute = .forceLeftToRight
            self.webAddress.semanticContentAttribute = .forceLeftToRight
            self.mobileNumber.semanticContentAttribute = .forceLeftToRight
            self.seperator.semanticContentAttribute = .forceLeftToRight
        }
        isRTL = !isRTL
    }
}
