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
    @IBOutlet weak var pwdField: FancyField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailField.delegate = self
        self.pwdField.delegate = self
    }
    
    

}
