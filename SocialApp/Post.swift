 //
//  Post.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/24/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import Foundation
import Firebase

class Post {
    fileprivate var _caption: String!
    fileprivate var _imageUrl: String!
    fileprivate var _likes: Int!
    fileprivate var _postKey: String!
    fileprivate var _postRef: FIRDatabaseReference!
    fileprivate var _userUID: String!
    fileprivate var _postedDate: String!

    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var userUID: String {
        return _userUID
    }
    
    var postedDate: String {
        return _postedDate
    }
    
    
    init(caption: String, imageUrl: String, likes: Int, userUID: String, postedDate: String) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._userUID = userUID
        self._postedDate = postedDate
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData[CAPTION_DB_STRING] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData[IMAGEURL_DB_STRING] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData[LIKES_DB_STRING] as? Int {
            self._likes = likes
        }
        
        if let userUID = postData[USER_DB_STRING] as? String {
            self._userUID = userUID
        }
        
        if let postedDate = postData[POSTED_DATE] as? String {
            self._postedDate = postedDate
        }

        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
    }
    
    func adjustLikes(_ addLike: Bool) {
        if addLike {
           _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child(LIKES_DB_STRING).setValue(_likes)
        
        
    }
}
