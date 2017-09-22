//
//  Post.swift
//  RedditDemo
//
//  Created by Egidijus Ambrazas on 14/09/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import Foundation

class Subreddit {
    let title: String
    let thumbnailUrl: URL?
    let id: String
    let permalink: String
    let comments: Int
    var favorite: Bool
    
    init(title: String, thumbnailUrl: URL?, id: String, permalink:String, comments: Int) {
        self.title = title
        self.thumbnailUrl = thumbnailUrl
        self.id = id
        self.permalink = permalink
        self.comments = comments
        self.favorite = false
        
    }
    
}


