//
//  GADBannerViewDelegate.swift
//  Image for Instagram
//
//  Created by Saud Almutlaq on 16/05/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//
import GoogleMobileAds

/**
 var bannerView: GADBannerView!
 var interstitial: GADInterstitial!
 var rewardedAd: GADRewardedAd?
 */
extension NewCardViewController: GADBannerViewDelegate {
    
    func initBannerAdView(withUnitID unitID: String, andTag unitTag: Int) -> GADBannerView? {
        var prepBannerView = GADBannerView()
        
        // In this case, we instantiate the banner with desired ad size.
        prepBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        prepBannerView.adUnitID = unitID
        prepBannerView.tag = unitTag
        prepBannerView.delegate = self
        prepBannerView.rootViewController = self
        prepBannerView.load(GADRequest())
        
        return prepBannerView
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
