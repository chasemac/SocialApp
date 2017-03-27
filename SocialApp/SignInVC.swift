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


class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailField.delegate = self
        self.pwdField.delegate = self
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
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
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
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("CHASE: unable to authenticate with Firebase user email")
                        } else {
                            print("CHASE: Succesffully authentitcated with Firebase email")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
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
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("CHASE: Data saved to keychaise \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

