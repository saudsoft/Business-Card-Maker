//
//  ViewController.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 15/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import PhoneNumberKit
import CoreData

class NewCardViewController: UIViewController, CNContactViewControllerDelegate, CNContactPickerDelegate {

    @IBOutlet weak var cardTitle: UITextField!
    @IBOutlet weak var givenName: UITextField!
    @IBOutlet weak var middleName: UITextField!
    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var orgName: UITextField!
    @IBOutlet weak var mobileNumber: PhoneNumberTextField!
    @IBOutlet weak var faxNumber: PhoneNumberTextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var webAddress: UITextField!
    
    var vCards: [NSManagedObject] = []
    
    func openVCard(for cnContact: CNContact) {
        let contactViewController = CNContactViewController(forUnknownContact: cnContact)
        contactViewController.view.backgroundColor = .white
        contactViewController.contactStore = CNContactStore()
        contactViewController.delegate = self
        
        self.navigationController?.pushViewController(contactViewController, animated: true)
    }
    
    func newVCard() {
        let contactViewController = CNContactViewController(forNewContact: nil)
        contactViewController.view.backgroundColor = .white
        contactViewController.contactStore = CNContactStore()
        contactViewController.delegate = self
        
        self.navigationController?.pushViewController(contactViewController, animated: true)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print(contact?.givenName ?? "NA")
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("createNewCard", comment: "Create New Card")
        
        cardTitle.becomeFirstResponder()
        self.prepareFields()
        

        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        cardTitle.delegate = self
        givenName.delegate = self
        middleName.delegate = self
        familyName.delegate = self
        jobTitle.delegate = self
        orgName.delegate = self
        mobileNumber.delegate = self
        faxNumber.delegate = self
        emailAddress.delegate = self
        webAddress.delegate = self
        
        self.addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.nextButtonAction))
        let prev: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.prevButtonAction))
        prev.width = 50
        next.width = 50
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(next)
        items.append(prev)

        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
//        self.cardTitle.inputAccessoryView = doneToolbar
//        self.givenName.inputAccessoryView = doneToolbar
//        self.middleName.inputAccessoryView = doneToolbar
//        self.familyName.inputAccessoryView = doneToolbar
        self.mobileNumber.inputAccessoryView = doneToolbar
        self.faxNumber.inputAccessoryView = doneToolbar
    }
    
    var activeTextField = UITextField()
    
    // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    @objc func nextButtonAction() {
        if mobileNumber.isFirstResponder {
            faxNumber.becomeFirstResponder()
        } else {
            emailAddress.becomeFirstResponder()
        }
    }
    
    @objc func prevButtonAction() {
        if faxNumber.isFirstResponder {
            mobileNumber.becomeFirstResponder()
        } else {
            orgName.becomeFirstResponder()
        }
    }
    
    func prepareFields() {
        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["SA"]

        self.mobileNumber.withPrefix = true
        self.mobileNumber.withFlag = true
        self.mobileNumber.withExamplePlaceholder = true

        self.faxNumber.withPrefix = true
        self.faxNumber.withFlag = true
        self.faxNumber.withExamplePlaceholder = true

    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func saveCard(button: UIButton) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)

        let contact = SSCContact(withCardTitle: cardTitle.text!, givenName: givenName.text!, middleName: middleName.text!, familyName: familyName.text!, mobileNumber: mobileNumber.text!, emailAddress: emailAddress.text!, webAddress: webAddress.text!, faxNumber: faxNumber.text!, jobTitle: jobTitle.text!, orgnizationName: orgName.text!)
        
        print(contact.faxNumber)
        save(cnCard: contact)
    }
    
    func save(cnCard: SSCContact) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let card = Card(context: managedContext)
        
        // 3
        card.cardTitle = cnCard.cardTitle
        card.givenName = cnCard.givenName
        card.middleName = cnCard.middleName
        card.familyName = cnCard.familyName
        card.jobTitle = cnCard.jobTitle
        card.emailAddress = cnCard.emailAddress
        card.websiteURL = cnCard.websiteURL
        card.faxNumber = cnCard.faxNumber
        card.mobileNumber = cnCard.mobileNumber
        card.orgnizationName = cnCard.orgnizationName
        
        // 4
        do {
            try managedContext.save()
            
            vCards.append(card)
            
            let alert = UIAlertController(title: NSLocalizedString("success", comment: "Success"), message: NSLocalizedString("cardSaved", comment: "Card Saved."), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "Ok"), style: .default, handler: {(_) in
                self.dismiss(animated: true, completion: nil)
                _ = self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true)
            
            print("Card Saved!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear - before if")
        
        if let firstVC = presentingViewController as? CardsViewController {
            print("viewWillDisappear - inside if")

            DispatchQueue.main.async {
                firstVC.loadData()
            }
        }
    }
}
