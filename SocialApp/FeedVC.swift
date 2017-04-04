//
//  FeedVC.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/22/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()

    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        DataService.ds.REF_POSTS.queryOrdered(byChild: POSTED_DATE).observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.insert(post, at: 0)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post, img: img)
                tableView.rowHeight = UIScreen.main.bounds.size.width + 170
                
                
            } else {
                tableView.rowHeight = UIScreen.main.bounds.size.width + 170
                cell.configureCell(post)
                
              //  tableView.rowHeight = cell.contentView.frame.height (cell.imageView?.frame.height)! +
            }
            return cell
        } else {
            return PostCell()
        }
        
        
    }
    

    
    
    
    
    @IBAction func addImageTapped(_ sender: Any) {
       performSegue(withIdentifier: "createPostSegue", sender: nil)
      //  present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewComments" {
            let nextVC = segue.destination as! ViewCommentsVC
            nextVC.post = sender as! Post
        }
    }
    
    func singOut() {
        let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("CHASE: ID Removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        self.performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        let destructiveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("Signed Out")
            self.singOut()
        }
        let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        

    }
    @IBAction func profileTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "editProfile", sender: nil)
    }
    
    @IBAction func commentBtnTapped(_ sender: Any) {
       // self.performSegue(withIdentifier: "viewComments", sender: Post)
    }
    


    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}
