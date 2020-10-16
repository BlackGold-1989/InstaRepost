//
//  ResultVC.swift
//  InstaRepost
//
//  Created by Jamie Nguyen on 9/15/17.
//  Copyright © 2017 FPT. All rights reserved.
//

import UIKit
import SVProgressHUD


class ResultVC: UIViewController {
    
    
    @IBOutlet weak var resultImageView: UIImageView!
    var resultImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultImageView.image = resultImage
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
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if resultImage != nil {
            UIImageWriteToSavedPhotosAlbum(resultImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            //Error saving image
            SVProgressHUD.showError(withStatus: "Fail")
            return
        }
        //Image saved successfully
        SVProgressHUD.showSuccess(withStatus: "Success")
    }
    
    @IBAction func uploadToInstagramTapped(_ sender: UIButton) {
        if resultImage != nil {
            if gFlgVideo {
                InstagramManager.sharedManager.postVideoToInstagramWithCaption(instagramCaption: "", view: self.view)
            } else {
                InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram: resultImage!, instagramCaption: "", view: self.view)
            }
        }        
    }
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
