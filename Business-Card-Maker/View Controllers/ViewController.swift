//
//  ViewController.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 18/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {
    var mainBannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var myRewardedAd: GADRewardedAd?
    
    @IBOutlet weak var showCardTitle: UILabel!
    @IBOutlet weak var newCardTitle: UILabel!
    @IBOutlet weak var adViewForBannerView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        
        populateAds()
    }
    
    func showInterstitialAd() {
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
    }
    
    func populateAds() {
        if !isPremiumCustomer() {
            mainBannerView = initBannerAdView(withUnitID: GADTest.bannerID, andTag: 1)
            addBannerViewToView(mainBannerView)
            
            // Interstitial Ad Init
            self.initInterstitialAdView(withUnitID: GADTest.interstitialID)
            if !didShowInterstitialAd {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
                    // Code you want to be delayed
                    didShowInterstitialAd = true
//                    self.showInterstitialAd()
                }
            }
        } else {
            removeAdViews()
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        if bannerView.tag == 1 {
            self.adViewForBannerView.addSubview(bannerView)
        }
    }
    
    func removeAdViews() {
        if self.adViewForBannerView != nil {
            self.adViewForBannerView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateAds()
        
        UserDefaults.standard.set(0, forKey: UserDefaults.keys.selectedItemIndex)
        // Do any additional setup after loading the view.
        showCardTitle.text = NSLocalizedString("showMyCard", comment: "My Cards")
        newCardTitle.text = NSLocalizedString("createCard", comment: "Create Card")
    }
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.

        showInterstitialAd()

     }
     
    
}

//MARK - GADInterstitialDelegate
extension ViewController: GADInterstitialDelegate {
    func initInterstitialAdView(withUnitID unitID:String) {
        interstitial = GADInterstitial(adUnitID: unitID)
        interstitial.delegate = self
        if !interstitial.isReady {
            print("\(interstitial.isReady) Request new Intertitial Ad")
            let request = GADRequest()
            interstitial.load(request)
        }
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        //        interstitial = nil
        //        initInterstitialAdView()
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}


//MARK - GADBannerViewDelegate

/**
 var bannerView: GADBannerView!
 var interstitial: GADInterstitial!
 var rewardedAd: GADRewardedAd?
 */
extension ViewController: GADBannerViewDelegate {
    
    func initBannerAdView(withUnitID unitID: String, andTag unitTag: Int) -> GADBannerView? {
        var prepBannerView = GADBannerView()
        
        // In this case, we instantiate the banner with desired ad size.
        prepBannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
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

