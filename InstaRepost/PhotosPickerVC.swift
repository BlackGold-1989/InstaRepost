//
//  PhotosPickerVC.swift
//  InstaRepost
//
//  Created by Jamie Nguyen on 9/15/17.
//  Copyright © 2017 FPT. All rights reserved.
//

import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos

class PhotosPickerVC: UIViewController  {
    @IBOutlet weak var pickerView: UIView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
//            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    // image picked
                    let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let resultVC:ResultVC = mainStoryBoard.instantiateViewController(withIdentifier: "ResultVCIdentifier") as! ResultVC
                    resultVC.resultImage = photo.image
                    
                    self.navigationController?.pushViewController(resultVC, animated: true)
                case .video(let _): break
                    //
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func photoTapped(_ sender: UIButton) {
//        imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        self.addChildViewController(imagePicker)
//        pickerView.addSubview(imagePicker.view)
    }
    
    @IBAction func libraryTapped(_ sender: UIButton) {
//        imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .savedPhotosAlbum
//        self.addChildViewController(imagePicker)
//        pickerView.addSubview(imagePicker.view)
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
