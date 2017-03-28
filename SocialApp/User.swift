//
//  User.swift
//  SocialApp
//
//  Created by Chase McElroy on 3/28/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//
/*
import Foundation
import Firebase
class User {
    private var _name: String!
    private var _likes: Int!
    private var _provider: String!
    
    private var _profileImageUrl: String!
    private var _username: String!
    private var _userUID: String!
    
    private var _userRef: FIRDatabaseReference!
    
    
    var name: String {
        return _name
    }
    
    var profileImageUrl: String {
        return _profileImageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var provider: String {
        return _provider
    }
    
    var username: String {
        return _username
    }
    
    var userUID : String {
        return _userUID
    }
    
    
    
    init(name: String, profileImageUrl: String, likes: Int, username: String, userUID: String) {
        self._name = name
        self._profileImageUrl = profileImageUrl
        self._likes = likes
        self._username = username
        self._userUID = userUID
    }
    
    init(userUID: String, postData: Dictionary<String, AnyObject>) {
        self._userUID = userUID
        
        if let profileImageUrl = postData[PROFILE_IMAGEURL_DB_STRING] as? String {
            self._profileImageUrl = profileImageUrl
        }
        
        if let username = postData[USERNAME_DB_STRING] as? String {
            self._username = username
        }
        
        if let userUID = postData[USER_DB_STRING] as? String {
            self._userUID = userUID
        }
        
        
        _userRef = DataService.ds.REF_POSTS.child(userUID)
    }
    
    
}
 */
