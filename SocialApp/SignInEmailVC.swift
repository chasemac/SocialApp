//
//  SignInEmailVC.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/30/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class SignInEmailVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var validEmailAddress: UIImageView!
    @IBOutlet weak var pwdCharactersLong: UIImageView!
    @IBOutlet weak var pwdCharacterLowerCase: UIImageView!
    @IBOutlet weak var pwdCharacterUpperCase: UIImageView!
    @IBOutlet weak var pwdCharacterNumber: UIImageView!

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailField.delegate = self
        self.pwdField.delegate = self
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
                        self.completeSignIn(id: user.uid, userData: userData)
                    } else {
                        let userData = [PROVIDER_DB_STRING: credential.provider,
                                        EMAIL_DB_STRING: user.email!,
                                        ]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                }
            }
        })
    }

    
    @IBAction func signInBtnPressed(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("CHASE: EMAIL User authenticated with Firebase")
                    if let user = user {
                        let userData = [PROVIDER_DB_STRING: user.providerID,
                                        EMAIL_DB_STRING: email]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("CHASE: unable to authenticate with Firebase user email")
                        } else {
                            print("CHASE: Succesffully authentitcated with Firebase email")
                            if let user = user {
                                let userData = ["provider": user.providerID,
                                                EMAIL_DB_STRING: email]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }

    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        // Save Data to keychain
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("CHASE: Data saved to keychaise \(keychainResult)")
        
        // Check if Username exist
        DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(USERNAME_DB_STRING) {
                self.performSegue(withIdentifier: "goToFeedFromEmail", sender: nil)
            } else {
                print("username doesn't exist")
                self.performSegue(withIdentifier: "createProfileFromEmail", sender: nil)
            }
        })
    }
    
    
    @IBAction func forgotPasswordBtnPressed(_ sender: Any) {
        
    }
    

    // MARK: KEYBOARD FUNCTIONS
    // Move View
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    // Keyboard shows
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -250, up: true)
    }
    
    // Keyboard is hidden
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -250, up: false)
    }
    
    //presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        pwdField.resignFirstResponder()
        return true
    }
    
    // Hide keyboard when user touches outside keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
