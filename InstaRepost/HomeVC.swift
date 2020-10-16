//
//  HomeVC.swift
//  InstaRepost
//
//  Created by Jamie Nguyen on 9/15/17.
//  Copyright © 2017 FPT. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import SVProgressHUD
import YPImagePicker
import AVFoundation
import AVKit
import Photos

class HomeVC: UIViewController {
    var selectedItems = [YPMediaItem]()
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var freeTrialButton: UIButton!
    @IBOutlet weak var detailsInfoTextView: UITextView!
    @IBOutlet weak var trialtextview: UITextView!
    
    let productIdentifier = "com.sg.interclick.repostforinstagramstories.monthly"
    let secretKey = "0cfe90c9cd0b466294378380c3740c90"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIForPurchase()
        initClickableTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startFreeTrialTapped(_ sender: UIButton) {
//        self.showMainFuction()

        let purchased = UserDefaults.standard.bool(forKey: "Purchased")
        if purchased == false {
            self.purchase()
        }else {
            self.showMainFuction()
        }
    }
    
    func updateUIForPurchase(){
        let isPurchased = UserDefaults.standard.bool(forKey: "Purchased")
        detailsButton.isHidden = isPurchased
        restoreButton.isHidden = isPurchased
        detailsInfoTextView.isHidden = isPurchased
        trialtextview.isHidden = isPurchased
        let title = isPurchased ? "Make a New Story" : "FREE TRIAL"
        freeTrialButton.setTitle(title, for: .normal)
    }
    
    func showMainFuction () {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetMediumQuality
        config.startOnScreen = .library
        config.screens = [.library, .photo, .video]
        config.video.libraryTimeLimit = 500.0
        config.showsCrop = .rectangle(ratio: (16/9))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false

        config.library.maxNumberOfItems = 5
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            self.selectedItems = items
            if let firstItem = items.first {
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let resultVC:ResultVC = mainStoryBoard.instantiateViewController(withIdentifier: "ResultVCIdentifier") as! ResultVC
                switch firstItem {
                case .photo(let photo):
                    // image picked
                    resultVC.resultImage = photo.image
                    gFlgVideo = false
                case .video(let video):
                    // video picked
                    resultVC.resultImage = video.thumbnail
                    gFlgVideo = true
                    
                    let url = video.url
                    // check if video is compatible with album
                    let compatible: Bool = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                    // save
                    if compatible {
                        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
                        print("saved!!!! \(String(describing: url.path))")
                    }
                    gUrlVideo = url //save url to send next function play video
                }
                if (!picker.viewControllers.contains(resultVC)) {
                    picker.pushViewController(resultVC, animated: true)
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    func purchase () {
        SVProgressHUD.show(withStatus: "Loading")
        SwiftyStoreKit.purchaseProduct(productIdentifier, atomically: false) { result in
            SVProgressHUD.dismiss()
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verifyReceipt()
            } else {
                // purchase error
                self.updateUIForPurchase()
            }
        }
    }
    
    func verifyReceipt() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: secretKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            SVProgressHUD.dismiss()
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: self.productIdentifier,
                    inReceipt: receipt)                
                switch purchaseResult {
                case .purchased( _, _):
                    UserDefaults.standard.set(true, forKey: "Purchased")
                    
                    self.showMainFuction()
                    self.showAlert(title: "", message: "Purchase success!")
                case .expired( _, _):
                    UserDefaults.standard.set(false, forKey: "Purchased")
                    
                    self.showAlert(title: "", message: "Expired!")
                case .notPurchased:
                    UserDefaults.standard.set(false, forKey: "Purchased")
                    
                    self.showAlert(title: "", message: "Purchase fail!")
                }
                self.updateUIForPurchase()
            } else {
                // receipt verification error
                self.updateUIForPurchase()
            }
        }
    }
    
    
    @IBAction func restorePurchaseTapped(_ sender: UIButton) {
        let purchased = UserDefaults.standard.bool(forKey: "Purchased")
        if purchased == false {
            self.restore ()
        }else {
            self.showMainFuction()
        }
        
    }
    
    func restore () {
        SVProgressHUD.show(withStatus: "Loading")
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            SVProgressHUD.dismiss()
            if results.restoreFailedPurchases.count > 0 {
                self.showAlert(title: "", message: "Restore Failed")
                UserDefaults.standard.set(false, forKey: "Purchased")
                self.updateUIForPurchase()
            }
            else if results.restoredPurchases.count > 0 {
                var isSuccess = false
                for restoredPurchase in results.restoredPurchases {
                    if restoredPurchase.productId == self.productIdentifier {
                        self.showMainFuction()
                        self.showAlert(title: "", message: "Restore Success")
                        UserDefaults.standard.set(true, forKey: "Purchased")
                        isSuccess = true
                        break
                    }
                }
                if !isSuccess {
                    self.showAlert(title: "", message: "Restore Failed")
                    UserDefaults.standard.set(false, forKey: "Purchased")
                    self.updateUIForPurchase()
                }
            }
            else {
                UserDefaults.standard.set(false, forKey: "Purchased")
                self.updateUIForPurchase()
                self.showAlert(title: "", message: "Nothing to Restore")
            }
        }
    }
    
    func showAlert (title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func initClickableTextView(){
        let linkAttributes: [String : Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.blue,
            NSAttributedStringKey.underlineColor.rawValue: UIColor.blue,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue]
        detailsInfoTextView.linkTextAttributes = linkAttributes
        
        detailsInfoTextView.attributedText = self.getAttributedString()
        detailsInfoTextView.delegate = self
        detailsInfoTextView.isUserInteractionEnabled = true
        detailsInfoTextView.isSelectable = true
        detailsInfoTextView.isEditable = false
        detailsInfoTextView.contentOffset = CGPoint.zero
    }
    
    func getAttributedString() -> NSMutableAttributedString {
        let termCondition = "Terms of Service"
        let policy = "Privacy Policy"
        let title = "Recurring Billing. Cancel any time \n * After the free trial ends, subscription payment of $6.99 per week will be charged to your iTunes Account, and your account will be charged 24 hours prior to the current period. Auto-renewal maybe turned off at any time by going to your settings in iTunes store after purchase. For more information, please visit our \(termCondition) and \(policy)."
        
        let urlLink = "http://interclickmedia.com/instarepost/privacypolicy.html"
        let policyLink = "http://interclickmedia.com/instarepost/privacypolicy.html"

        let str = NSMutableAttributedString(string: title,
                                        attributes:[NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.systemFont(ofSize: 11, weight: UIFont.Weight.regular),
                                                    NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black])        
        let foundRange = str.mutableString.range(of: termCondition)
        if foundRange.location != NSNotFound {
            str.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.link.rawValue), value: urlLink, range: foundRange)
        }
        let foundRangePolicy = str.mutableString.range(of: policy)
        if foundRangePolicy.location != NSNotFound {
            str.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.link.rawValue), value: policyLink, range: foundRangePolicy)
        }
        return str
    }
}

extension HomeVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

