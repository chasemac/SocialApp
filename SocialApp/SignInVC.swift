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

// /Users/chasemcelroy/Development/Tutorials/SocialApp/SocialApp/SignInVC.swift:38:72: Use 'String(describing:)' to silence this warning

class SignInVC: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.stringForKey(KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                // Swith
                print("CHASE: unable to authenticate with facebook - \(String(describing: error))")
                
            } else if result?.isCancelled == true {
                print("CHASE: user canceled")
            } else {
                print("CHASE: Successfully authenticated with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
                
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in

            if error != nil {
                print("CHASE: Unable to auth with Firebase - \(String(describing: error))")
                
            } else {
                print("CHASE: Succesffully authenticated with Firebase")
                if let user = user {
                    if user.photoURL != nil {
                        let userData = [PROVIDER_DB_STRING: credential.provider,
                                        EMAIL_DB_STRING: user.email!,
                                        NAME_DB_STRING: user.displayName!,
                                        FACEBOOK_PROFILE_IMAGEURL_DB_STRING: user.photoURL!.absoluteString as String
                        ]
                        self.completeSignIn(user.uid, userData: userData)
                    } else {
                        let userData = [PROVIDER_DB_STRING: credential.provider,
                                        EMAIL_DB_STRING: user.email!,
                        ]
                        self.completeSignIn(user.uid, userData: userData)
                    }
                }
            }
        })
    }
    
    
    func completeSignIn(_ id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(id, userData: userData)
               // Save Data to keychain
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("CHASE: Data saved to keychaise \(keychainResult)")
        
        // Check if Username exist
        DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(USERNAME_DB_STRING) {
                self.performSegue(withIdentifier: "goToFeed", sender: nil)
            } else {
                print("username doesn't exist")
                self.performSegue(withIdentifier: "createProfile", sender: nil)
            }
        })
    }
    
    @IBAction func emailBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "emailSegue", sender: nil)
    }
    
   }

