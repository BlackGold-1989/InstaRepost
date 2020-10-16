//
//  WebViewVC.swift
//  InstaRepost
//
//  Created by Jamie Nguyen on 10/16/17.
//  Copyright © 2017 FPT. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


class WebViewVC: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()




        let string = NSString(string:textView.text)
        let linkString = NSMutableAttributedString(string: textView.text)

        let range = string.range(of: "Terms of Service")
        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.link.rawValue), value: NSURL(string: "http://interclickmedia.com/instarepost/tos.html")!, range: range)

        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue), value: UIFont(name: "HelveticaNeue", size: 13.0)!, range: range)


        let range2 = string.range(of: "Privacy Policy")
        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.link.rawValue), value: NSURL(string: "http://interclickmedia.com/instarepost/privacypolicy.html")!, range: range2)

        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue), value: UIFont(name: "HelveticaNeue", size: 13.0)!, range: range2)

        let range3 = string.range(of: "contact us")
        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.link.rawValue), value: NSURL(string: "mailto://interclickmedia@outlook.com")!, range: range3)

        linkString.addAttribute(NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue), value: UIFont(name: "HelveticaNeue", size: 13.0)!, range: range3)

        textView.attributedText = linkString
        textView.delegate = self
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true

        textView.alpha = 0
        let when = DispatchTime.now() + 0.25 // change 1 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
           self.textView.alpha = 1
           self.textView.setContentOffset(CGPoint.zero, animated: true)
        }

    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "mailto" {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        UIApplication.shared.openURL(URL)
        return true
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients(["interclickmedia@outlook.com"])
//        mailComposerVC.setSubject("Sending you an in-app e-mail...")
//        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
