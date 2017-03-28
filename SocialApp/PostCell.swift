//
//  PostCell.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/23/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var profileImageUrlRef: FIRDatabaseReference!
    var usernameRef: FIRDatabaseReference!
    
    var users = [User]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child(LIKES_DB_STRING).child(post.postKey)
        usernameRef = DataService.ds.REF_USERS.child(post.userUID).child(USERNAME_DB_STRING)
        profileImageUrlRef = DataService.ds.REF_USERS.child(post.userUID).child(PROFILE_IMAGEURL_DB_STRING)
        
        usernameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.usernameLbl.text = post.userUID
            } else {
                self.usernameLbl.text = snapshot.value as? String
            }
        })
        
        profileImageUrlRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                print("something went wrong \(snapshot)")
            } else {
                print(snapshot)
            }
        })
        
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"

    
        self.usernameLbl.text = post.userUID
        
        
        if img != nil {
            self.postImg.image = img
            
            
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("CHASE: Unable to download image from firebase storage")
                } else {
                    print("Image downloaded from FB Storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                        self.postImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }

}

