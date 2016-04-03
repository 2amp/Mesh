//
//  ADProfileViewController.swift
//  Mesh
//
//  Created by Christopher Fu on 4/2/16.
//  Copyright © 2016 2amp. All rights reserved.
//

import UIKit
import Parse

class ADProfileViewController: UIViewController {
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var affiliationTF: UITextField!
    @IBOutlet var phoneTF: UITextField!
    @IBOutlet var emailTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGestureRecognizer))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
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
        let profile = PFObject(className: "ADProfile",
                               dictionary: [
                                "name": name,
                                "affiliation": affiliation,
                                "phone": phone,
                                "email": email
            ])
        profile.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) in
            guard success else {
                self.showAlert(title: "Error", message: "Error saving profile.")
                return
            }
        })
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
