//
//  ADProfileViewController.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import Parse

class ADProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var ProfileImage: UIImageView!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var affiliationTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var saveAIV: UIActivityIndicatorView!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var profileButton: UIButton!

    let defaults = NSUserDefaults.standardUserDefaults()

    let imagePicker = UIImagePickerController()

    
    @IBAction func Nuke(sender: UIButton){
        defaults.setObject(nil, forKey:"name")
        nameTF.text = nil
        defaults.setObject(nil, forKey:"affiliation")
        affiliationTF.text = nil
        defaults.setObject(nil, forKey: "phone")
        phoneTF.text = nil
        defaults.setObject(nil, forKey: "email")
        emailTF.text = nil
        defaults.setObject(nil, forKey:"pic")
        ProfileImage.image = nil
        profileButton.setTitle("Add Image", forState: .Normal)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let domain = NSBundle.mainBundle().bundleIdentifier
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domain!)

        // Do any additional setup after loading the view.
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)

        // Let users pick an image
        imagePicker.delegate = self
        ProfileImage.layer.borderWidth = 1
        ProfileImage.layer.masksToBounds = false
        ProfileImage.layer.borderColor = UIColor.blackColor().CGColor
        ProfileImage.layer.cornerRadius = ProfileImage.frame.height/2
        ProfileImage.clipsToBounds = true

        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, nameTF.frame.size.height - 1, nameTF.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        nameTF.layer.addSublayer(bottomBorder)

        bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, affiliationTF.frame.size.height - 1, affiliationTF.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        affiliationTF.layer.addSublayer(bottomBorder)

        bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, phoneTF.frame.size.height - 1, phoneTF.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        phoneTF.layer.addSublayer(bottomBorder)

        bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, emailTF.frame.size.height - 1, emailTF.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        emailTF.layer.addSublayer(bottomBorder)

        //Check if defaults
        if defaults.stringForKey("name") != nil{
            nameTF.text = defaults.stringForKey("name")
        }
        if defaults.stringForKey("affiliation") != nil{
            affiliationTF.text = defaults.stringForKey("affiliation")
        }
        if defaults.stringForKey("phone") != nil{
            phoneTF.text = defaults.stringForKey("phone")
        }
        if defaults.stringForKey("email") != nil{
            emailTF.text = defaults.stringForKey("email")
        }
        if defaults.dataForKey("pic") != nil{
            ProfileImage.image = UIImage(data: defaults.dataForKey("pic")!)
            ProfileImage.contentMode = .ScaleAspectFill

        }
        else{
            ProfileImage.image = nil
            profileButton.setTitle("Add Image", forState: .Normal)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleSwipeGestureRecognizer() {
        view.endEditing(true)
    }

    @IBAction func saveTapped() {
        let name = nameTF.text!
        let affiliation = affiliationTF.text!
        let phone = phoneTF.text!
        let email = emailTF.text!
        guard !name.isEmpty else {
            self.showAlert(title: "Error", message: "Please enter a name.")
            return
        }
        guard !affiliation.isEmpty else {
            self.showAlert(title: "Error", message: "Please enter an affiliation.")
            return
        }
        guard !phone.isEmpty else {
            self.showAlert(title: "Error", message: "Please enter a phone number.")
            return
        }
        guard !email.isEmpty else {
            self.showAlert(title: "Error", message: "Please enter an email.")
            return
        }

        defaults.setObject(name, forKey:"name")
        defaults.setObject(affiliation, forKey:"affiliation")
        defaults.setObject(phone, forKey: "phone")
        defaults.setObject(email, forKey: "email")

        if ProfileImage != nil{
            let pic = UIImageJPEGRepresentation(ProfileImage.image!, 1.5)
            defaults.setObject(pic, forKey:"pic")
           profileButton.setTitle("", forState: .Normal)
        }

        let profile = PFObject(className: "ADProfile",
                               dictionary: [
                                "name": name,
                                "affiliation": affiliation,
                                "phone": phone,
                                "email": email
            ])
        profile.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) in
            self.saveAIV.stopAnimating()
            self.saveBtn.setTitle("Save", forState: .Normal)
            guard success else {
                self.showAlert(title: "Error", message: "Error saving profile.")
                return
            }

            let toView = self.tabBarController!.viewControllers![0].view

            if !self.defaults.boolForKey("isSet") {
                let query = PFQuery(className: "CurrentMajorMinor")
                do {
                    let cmm = try query.findObjects()[0]
                    var major = cmm["major"] as! Int
                    var minor = cmm["minor"] as! Int
                    self.defaults.setInteger(major, forKey: "major")
                    self.defaults.setInteger(minor, forKey: "minor")
                    print("major: \(self.defaults.integerForKey("major")) minor: \(self.defaults.integerForKey("minor"))")
                    let broadcastVC = self.tabBarController!.viewControllers![0] as! BroadcastViewController
                    broadcastVC.major = major
                    broadcastVC.minor = minor
                    minor += 1
                    if minor > 65535 {
                        major += 1
                        minor = 1
                    }
                    cmm["major"] = major
                    cmm["minor"] = minor
                    cmm.saveInBackground()
                } catch let error as NSError {
                    print(error)
                }
                self.defaults.setBool(true, forKey: "isSet")
            }

            UIView.transitionFromView(self.view, toView: toView, duration: 0.5, options: .TransitionFlipFromRight, completion: {
                finished in
                self.tabBarController!.selectedIndex = 0
            })
        })
        saveAIV.startAnimating()
        saveBtn.setTitle("", forState: .Normal)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
