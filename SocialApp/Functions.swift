//
//  Functions.swift
//  SocialApp
//
//  Created by Chase McElroy on 4/5/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

func setupDefaultAlert(title: String, message: String, actionTitle: String, VC: UIViewController) {
    let successfulEmailSentAlertConroller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let alrighty = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
        
    })
    successfulEmailSentAlertConroller.addAction(alrighty)
    VC.present(successfulEmailSentAlertConroller, animated: true, completion: nil)
}


func completeSignIn(_ id: String, userData: Dictionary<String, String>, VC: UIViewController, usernameExistsSegue: String, userNameDNESegue: String) {
    print("we made it!!!!!!")
    DataService.ds.createFirebaseDBUser(id, userData: userData)
    // Save Data to keychain
    let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
    print("CHASE: Data saved to keychaise \(keychainResult)")
    
    // Check if Username exist
    DataService.ds.REF_USERS.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.hasChild(USERNAME_DB_STRING) {
            VC.performSegue(withIdentifier: usernameExistsSegue, sender: nil)
        } else {
            print("username doesn't exist")
            VC.performSegue(withIdentifier: userNameDNESegue, sender: nil)
        }
    })
    
}
