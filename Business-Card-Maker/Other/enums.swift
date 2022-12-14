//
//  enums.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 02/07/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import Foundation

// Constants

/// Holds Google AdMob test units ID's
enum GADTest {
    static let bannerID  = "ca-app-pub-3940256099942544/2934735716"
    static let interstitialID   = "ca-app-pub-3940256099942544/4411468910"
    static let interstitialVideoid  =  "ca-app-pub-3940256099942544/5135589807"
    static let rewardedVideoID  =  "ca-app-pub-3940256099942544/1712485313"
    static let nativeAdvancedID  =  "ca-app-pub-3940256099942544/3986624511"
    static let nativeAdvancedVideoID  =  "ca-app-pub-3940256099942544/2521693316"
}


/// Holds Google AdMob live units ID's
enum GADLive {
    static let bannerID  = "ca-app-pub-1257362510472337/1134900039"
    static let interstitialID   = "ca-app-pub-1257362510472337/9292236432"
//    static let interstitialVideoid  =  ""
    static let rewardedVideoID  =  ""
//    static let nativeAdvancedID  =  ""
//    static let nativeAdvancedVideoID  =  ""
}

/// Holds in-app purchase products ID
enum IAP {
    static let productID = ""
}

/// Holds VCard items title, its same as titles used in core data
enum vcTitles {
    static let cardTitle = "cardTitle"
    static let givenName = "givenName"
    static let middleName = "middleName"
    static let familyName = "familyName"
    static let mobileNumber = "mobileNumber"
    static let faxNumber = "faxNumber"
    static let emailAddress = "emailAddress"
    static let websiteURL = "websiteURL"
    static let jobTitle = "jobTitle"
    static let orgnizationName = "orgnizationName"
}
