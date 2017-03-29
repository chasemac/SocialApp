//
//  ProfileVC.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/28/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var nameTextField: FancyField!
    @IBOutlet weak var usernameTextField: FancyField!
    
    var imageSelected : Bool = false
    var imagePicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.nameTextField.delegate = self
        self.usernameTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImg.image = image
            imageSelected = true
        } else {
            print("CHASE: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func profileImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func signOutBtnTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("CHASE: ID Removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignInFromProfile", sender: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let name = nameTextField.text, name != "" else {
            print("CHASE: Caption must be entered")
            return
        }
        guard let username = usernameTextField.text, username != "" else {
            print("CHASE: Caption must be entered")
            return
        }
        guard let img = profileImg.image, imageSelected == true else {
            print("Chase an image has been selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("CHASE: unable to upload to firebase storage")
                } else {
                    print("CHASE: Successfully uploaded image to Firebase Storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
            NAME_DB_STRING: nameTextField.text! as AnyObject,
            PROFILE_IMAGEURL_DB_STRING: imgUrl as AnyObject,
            USERNAME_DB_STRING: usernameTextField.text! as AnyObject
        ]
        
        
        let firebasePost = DataService.ds.REF_USER_CURRENT
        
        print("CHASE: Here is the key: --- \(firebasePost)")
        firebasePost.updateChildValues(post)
        
        nameTextField.text = ""
        usernameTextField.text = ""
        imageSelected = false
        profileImg.image = UIImage(named: "add-image")
        self.performSegue(withIdentifier: "goFromProfiletoFeed", sender: nil)

    }
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        moveTextField(textField: textField, moveDistance: -100, up: true)
    }
    
    // Keyboard is hidden
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -100, up: false)
    }
    
    //presses return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        return true
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}
