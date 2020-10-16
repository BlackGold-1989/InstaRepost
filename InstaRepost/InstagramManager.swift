//
//  InstagramManager.swift
//  InstagramSDK
//
//  Created by Attila Roy on 23/02/15.
//  share image with caption to instagram

import Foundation
import UIKit
import AVFoundation
import AVKit

class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private var documentInteractionController = UIDocumentInteractionController()
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application
        let instagramURL = NSURL(string: kInstagramURL)
        
        if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
            let imageData = UIImageJPEGRepresentation(imageInstagram, 1.00)
            let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            
            try? imageData?.write(to: URL.init(fileURLWithPath: writePath), options: .atomicWrite)
            let fileURL = NSURL(fileURLWithPath: writePath)
            documentInteractionController = UIDocumentInteractionController(url: fileURL as URL)
            documentInteractionController.delegate = self
            documentInteractionController.uti = "com.instagram.exlusivegram"
            
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
        } else {
            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
        }
    }
    
    func postVideoToInstagramWithCaption(instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application
        let instagramURL = NSURL(string: kInstagramURL)
        
        if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
            documentInteractionController = UIDocumentInteractionController(url: gUrlVideo!)
            documentInteractionController.delegate = self
            documentInteractionController.uti = "com.instagram.exlusivegram"
            
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
        } else {
            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
        }
    }
}


