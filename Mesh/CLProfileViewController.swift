//
//  ProfileViewController.swift
//  Mesh
//
//  Created by Daniel Pak on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit

class CLProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var btnAction: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        imagePicker.delegate = self
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = false
        ProfileImage.layer.borderColor = UIColor.blackColor().CGColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ProfileImage.contentMode = .ScaleAspectFill
            ProfileImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
