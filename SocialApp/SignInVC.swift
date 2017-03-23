//
//  ViewController.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/9/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("CHASE: unable to authenticate with facebook - \(error)")
                
            } else if result?.isCancelled == true {
                print("CHASE: user canceled")
            } else {
                print("CHASE: Successfully authenticated with facebook")
                let credecntial = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credecntial)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("CHASE: Unable to auth with Firebase - \(error)")
                
            } else {
                print("CHASE: Succesffully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
                
            }
        })
    }
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("CHASE: EMAIL User authenticated with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("CHASE: unable to authenticate with Firebase user email")
                        } else {
                            print("CHASE: Succesffully authentitcated with Firebase email")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("CHASE: Data saved to keychaise \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

