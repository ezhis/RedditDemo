//
//  RedditController.swift
//  RedditDemo
//
//  Created by Egidijus Ambrazas on 14/09/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import Foundation
import UIKit

enum RedditResult {
    case success([Subreddit])
    case failure(Error)
    case inprogress
}
enum RedditError: Error {
    case invalidJSONData
    case sessionError
}

enum RedditStatus {
    case loading
    case completed
}

class RedditController {
    
    struct Constants {
        static let subredditsUlr =      "https://www.reddit.com/r/popular/top.json?after="
        static let baseUrl =            "https://www.reddit.com"
        static let subredditsListTitle = "Top"
        
        static let keyData =            "data"
        static let keyTitle =           "title"
        static let keyThumbnail =       "thumbnail"
        static let keyNumComments =     "num_comments"
        static let keyPermalink =       "permalink"
        static let subredditId =        "name"
        
        static let keyDataObject =      "data"
        static let keyChildrenArray =   "children"
    }
    
    static let shared = RedditController()
    
    var allLoadedSubreddits = [Subreddit]()
    var status = RedditStatus.completed
    
    private init(){
    }
    
    
    func fetchSureddits(after id:String, completion: @escaping (RedditResult) -> Void){
        if status == .loading {
            completion(RedditResult.inprogress)
            return
        }

        status = .loading
        let url = URL(string: "\(Constants.subredditsUlr)\(id)")!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processSubredditsRequest(data: data, error: error)
            
            OperationQueue.main.addOperation {
                self.status = .completed
                completion(result)
            }
        }
        task.resume()
    }
    
    func getListTitle() -> String {
        return Constants.subredditsListTitle
    }
    
    func getSubredditURL(forPermalink permalink:String) -> URL? {
        return URL(string: Constants.baseUrl.appending(permalink))
    }
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func subreddit(fromJSON json: [String: Any]) -> Subreddit? {
        
        guard let dataObjects = json[Constants.keyData] as? [String: AnyObject],
            let title = dataObjects[Constants.keyTitle] as? String,
            let thumbnailUrlString = dataObjects[Constants.keyThumbnail] as? String,
            let numComments = dataObjects[Constants.keyNumComments] as? Int,
            let permalink = dataObjects[Constants.keyPermalink] as? String,
            let id = dataObjects[Constants.subredditId] as? String
            else {
                return nil
        }

        return Subreddit(title: title, thumbnailUrl: URL(string: thumbnailUrlString), id: id, permalink: permalink, comments: numComments)
    }
    
    private func processSubredditsRequest(data: Data?, error: Error?) -> RedditResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
        guard
            let jsonDictionary = jsonObject as? [AnyHashable: Any],
            let dataObject = jsonDictionary[Constants.keyDataObject] as? [String: Any],
            let childrenArray = dataObject[Constants.keyChildrenArray] as? [[String: Any]]
            else {
                return .failure(RedditError.invalidJSONData)
        }
        
        var subredditsArray = [Subreddit]()
        for subredditJSON in childrenArray {
            if let subreddit = subreddit(fromJSON: subredditJSON) {
                subredditsArray.append(subreddit)
            }
        }
        
        if subredditsArray.isEmpty && !childrenArray.isEmpty {
            return .failure(RedditError.invalidJSONData)
        }
        
        allLoadedSubreddits.append(contentsOf: subredditsArray)
        return .success(subredditsArray)
    }
    
}


