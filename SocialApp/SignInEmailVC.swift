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

class SignInEmailVC: UIViewController, UITextFieldDelegate {
    
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
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            // SIGN IN USER
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("CHASE: EMAIL User authenticated with Firebase")
                    if let user = user {
                        let userData = [PROVIDER_DB_STRING: user.providerID,
                                        EMAIL_DB_STRING: email]
                        self.completeSignIn(user.uid, userData: userData)
                    }
                } else {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            setupDefaultAlert(title: "", message: "\(self.emailField.text!) does not exist", actionTitle: "Ok", VC: self)
                            print("invalid email")
                        case .errorCodeUserNotFound:
                            // CREATE USER
                            let alertController = UIAlertController(title: "Create New User?", message: "\(self.emailField.text!) user account does not exist", preferredStyle: UIAlertControllerStyle.alert)
                            let destructiveAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.destructive) {
                                (result : UIAlertAction) -> Void in

                                FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                                    if error != nil {
                                        print("CHASE: unable to authenticate with Firebase user email \(String(describing: error))!")
                                    } else {
                                        print("CHASE: Succesffully authentitcated with Firebase email")
                                        print("New User Created")
                                        if let user = user {
                                            let userData = ["provider": user.providerID,
                                                            EMAIL_DB_STRING: email]
                                            self.completeSignIn(user.uid, userData: userData)
                                        }
                                    }
                                })
                                
                            }
                            let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                                print("Cancel")
                            }
                            alertController.addAction(destructiveAction)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            
                        case .errorCodeTooManyRequests:
                            setupDefaultAlert(title: "", message: "Too many requests", actionTitle: "Ok", VC: self)
                            print("too many email attemps")
                        case .errorCodeAppNotAuthorized:
                            print("app not authorized")
                        case .errorCodeNetworkError:
                            print("network error")
                            setupDefaultAlert(title: "", message: "Unable to connect to the internet!", actionTitle: "Ok", VC: self)
                        default:
                            print("Create User Error: \(error!)")
                        }
                    }
                }
            })
        }
    }
    
    func completeSignIn(_ id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(id, userData: userData)
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
        emailField.resignFirstResponder()
        //      textFieldDidEndEditing(pwdField)
        if self.validEmailAddress.image == UIImage(named: "complete") {
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailField.text!, completion: { (error) in
                
                if error != nil {
                    if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            setupDefaultAlert(title: "", message: "\(self.emailField.text!) does not exist", actionTitle: "Ok", VC: self)
                            print("invalid email")
                        case .errorCodeUserNotFound:
                            setupDefaultAlert(title: "", message: "\(self.emailField.text!) does not exist", actionTitle: "Ok", VC: self)
                        case .errorCodeEmailAlreadyInUse:
                            print("in use")
                        case .errorCodeTooManyRequests:
                            setupDefaultAlert(title: "", message: "Too many requests", actionTitle: "Ok", VC: self)
                            print("too many email attemps")
                        case .errorCodeAppNotAuthorized:
                            print("app not authorized")
                        case .errorCodeNetworkError:
                            print("network error")
                            setupDefaultAlert(title: "", message: "Unable to connect to the internet!", actionTitle: "Ok", VC: self)
                        default:
                            print("Create User Error: \(error!)")
                            
                        }
                    }
                } else {
                    if self.emailField.text != nil {
                        setupDefaultAlert(title: "", message: "Reset Email Sent!", actionTitle: "Ok", VC: self)
                    }
                }
                
            })
            
        } else {
            
            setupDefaultAlert(title: "", message: "Type valid email address in email field", actionTitle: "Ok", VC: self)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Valid Email Address
        if (emailField.text?.contains("@"))! && (emailField.text?.contains("."))! {
            self.validEmailAddress.image = UIImage(named: "complete")
        } else {
            self.validEmailAddress.image = UIImage(named: "incomplete")
        }
        // Long Password
        if (pwdField.text?.characters.count)! > 7 {
            self.pwdCharactersLong.image = UIImage(named: "complete")
        } else {
            self.pwdCharactersLong.image = UIImage(named: "incomplete")
        }
        // Lower Case
        let lower = pwdField.text?.characters
        var output = ""
        
        for chr in lower! {
            let str = String(chr)
            if str.lowercased() != str {
                output += str
            }
        }
        if output != "" {
            self.pwdCharacterLowerCase.image = UIImage(named: "complete")
        } else {
            self.pwdCharacterLowerCase.image = UIImage(named: "incomplete")
        }
        // Upper Case
        let upper = pwdField.text?.characters
        var upperOutput = ""
        
        for chr in upper! {
            let str = String(chr)
            if str.uppercased() != str {
                upperOutput += str
            }
        }
        if upperOutput != "" {
            self.pwdCharacterUpperCase.image = UIImage(named: "complete")
        } else {
            self.pwdCharacterUpperCase.image = UIImage(named: "incomplete")
        }
        // Contains Number
        /*
         if (pwdField.text?.contains(String([1,2,3,4,5,6,7,8,9,0])) {
         self.pwdCharacterNumber.image = UIImage(named: "complete")
         } else {
         self.pwdCharacterNumber.image = UIImage(named: "incomplete")
         }
         */
        
        
        return true
    }
    
    
    func checkTextFor(textField: UITextView) {
        
    }
    
    
    
    // MARK: KEYBOARD FUNCTIONS
    // Move View
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
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
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Keyboard is hidden
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
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
