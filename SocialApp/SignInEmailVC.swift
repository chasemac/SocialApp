//
//  SignInEmailVC.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/30/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit

class SignInEmailVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    func checkEmailAddress(email: String) {
        // Check if Username exist
        
        
        DataService.ds.REF_USERS.child(EMAIL_DB_STRING).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(email) {
                print("we're good")
                
                self.performSegue(withIdentifier: "accountExists", sender: nil)
            } else {
                print("username doesn't exist")
                self.performSegue(withIdentifier: "accountDoesNotExists", sender: nil)
            }
        })
    }

    @IBAction func nextBtnTapped(_ sender: Any) {
        if emailField.text != "" {
            checkEmailAddress(email: emailField.text!)
        }
        
    }

}
