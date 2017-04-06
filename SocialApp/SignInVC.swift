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
                print("CHASE: unable to authenticate with facebook - \(String(describing: error))")
                setupDefaultAlert(title: "", message: "Unable to authenticate with Facebook", actionTitle: "Ok", VC: self)
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
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errCode {

                    case .errorCodeUserNotFound:
                        setupDefaultAlert(title: "", message: " does not exist", actionTitle: "Ok", VC: self)
                    case .errorCodeEmailAlreadyInUse:
                        setupDefaultAlert(title: "", message: "An account was previously created with your Facebook's email address, please click the email button and sign in using your email address and password", actionTitle: "Ok", VC: self)
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
                print("CHASE: Succesffully authenticated with Firebase")
                if let user = user {
                    if user.photoURL != nil {
                        let userData = [PROVIDER_DB_STRING: credential.provider,
                                        EMAIL_DB_STRING: user.email!,
                                        NAME_DB_STRING: user.displayName!,
                                        FACEBOOK_PROFILE_IMAGEURL_DB_STRING: user.photoURL!.absoluteString as String
                        ]
                        completeSignIn(user.uid, userData: userData, VC: self, usernameExistsSegue: "goToFeed", userNameDNESegue: "createProfile")
                    } else {
                        let userData = [PROVIDER_DB_STRING: credential.provider,
                                        EMAIL_DB_STRING: user.email!,
                        ]
                        completeSignIn(user.uid, userData: userData, VC: self, usernameExistsSegue: "goToFeed", userNameDNESegue: "createProfile")
                    }
                }
            }
        })
    }
    
    @IBAction func emailBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "emailSegue", sender: nil)
    }
    
   }

