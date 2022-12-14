//
//  SSCContact.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 16/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import Foundation
import Contacts
import UIKit
import CoreData

class SSCContact {
    var cardTitle:String
    var givenName:String
    var middleName:String
    var familyName:String
    var mobileNumber:String
    var emailAddress:String
    var websiteURL:String
    var faxNumber:String
    var jobTitle:String
    var orgnizationName:String

    init() {
        cardTitle = ""
        givenName = ""
        middleName = ""
        familyName = ""
        mobileNumber = ""
        emailAddress = ""
        websiteURL = ""
        faxNumber = ""
        jobTitle = ""
        orgnizationName = ""
    }
    
    init(withCardTitle cTitle:String, givenName gName:String, middleName mName:String, familyName fName:String, mobileNumber mobNum:String, emailAddress email:String, webAddress website:String, faxNumber faxNum:String, jobTitle jTitle:String, orgnizationName orgName:String) {
        
        cardTitle = cTitle
        givenName = gName
        middleName = mName
        familyName = fName
        mobileNumber = mobNum
        emailAddress = email
        websiteURL = website
        faxNumber = faxNum
        jobTitle = jTitle
        orgnizationName = orgName
    }
    
    func vCardToCNContact(vCard:NSManagedObject) -> SSCContact {
        let cTitle = vCard.value(forKeyPath: vcTitles.cardTitle) as? String
        let gName = vCard.value(forKeyPath: vcTitles.givenName) as? String
        let mName = vCard.value(forKeyPath: vcTitles.middleName) as? String
        let fName = vCard.value(forKeyPath: vcTitles.familyName) as? String
        let mNum = vCard.value(forKeyPath: vcTitles.mobileNumber) as? String
        let fNum = vCard.value(forKeyPath: vcTitles.faxNumber) as? String
        let eMl = vCard.value(forKeyPath: vcTitles.emailAddress) as? String
        let wURL = vCard.value(forKeyPath: vcTitles.websiteURL) as? String
        let jT = vCard.value(forKeyPath: vcTitles.jobTitle) as? String
        let oN = vCard.value(forKeyPath: vcTitles.orgnizationName) as? String
        
        let card = SSCContact(withCardTitle: cTitle!, givenName: gName!, middleName: mName!, familyName: fName!, mobileNumber: mNum!, emailAddress: eMl!, webAddress: wURL!, faxNumber: fNum!, jobTitle: jT!, orgnizationName: oN!)
        return card
    }
    
    func getContact() -> CNContact {
        // Creating a mutable object to add to the contact
        let contact = CNMutableContact()
        
//        contact.imageData = profileImage.pngData() //NSData() as Data // The profile picture as a NSData object
        
        contact.givenName = givenName
        contact.middleName = middleName
        contact.familyName = familyName
        contact.jobTitle = jobTitle
        contact.organizationName = orgnizationName
        
        let workEmail = CNLabeledValue(label:CNLabelWork, value:emailAddress as NSString)
        let workWebsite = CNLabeledValue(label: CNLabelWork, value: websiteURL as NSString)
        
        contact.emailAddresses = [workEmail]
        contact.urlAddresses = [workWebsite]
        
        let mobileNum = CNLabeledValue(
            label:CNLabelPhoneNumberMobile,
            value:CNPhoneNumber(stringValue:mobileNumber))
        let faxNum = CNLabeledValue(
            label:CNLabelPhoneNumberWorkFax,
            value:CNPhoneNumber(stringValue:faxNumber))
        
        contact.phoneNumbers = [mobileNum, faxNum]
        
        return contact
    }
    
    //goes from CnContact to Data
    func makeVCardData() -> Data {
        let cnContact = getContact()
        
        var vCardData=Data()
        do {
            try vCardData=CNContactVCardSerialization.data(with: [cnContact])
        } catch {
            print ("CNConact not serialized./n"+"Error is:/n"+error.localizedDescription)
            return vCardData
        }
        return vCardData
    }
    
    func makeQRCode() -> UIImage {
        let data = makeVCardData()
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let qrCodeImage = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: qrCodeImage)
            } else {
                print("Unable to make qrCodeImage from data with filter")
                return UIImage()
            }
        } else {
            print("Unable to find CIFilter named CIQRCodeGenerator")
            return UIImage()
        }
    }
}
