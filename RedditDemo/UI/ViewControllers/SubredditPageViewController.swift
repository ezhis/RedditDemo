//
//  SubredditPageViewController.swift
//  RedditDemo
//
//  Created by Egidijus Ambrazas on 17/09/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit

class SubredditPageViewController: UIViewController {
    
    struct ViewConstants {
        static let favoriteButtonSelectedImage = #imageLiteral(resourceName: "icons8-Star Filled-50")
        static let favoriteButtonNormalImage = #imageLiteral(resourceName: "icons8-Star-50")
        static let titleImage = #imageLiteral(resourceName: "icons8-Reddit Filled-50")
    }
    
    var subreddit:Subreddit?
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFavoriteIcon()
        navigationItem.titleView = UIImageView(image: ViewConstants.titleImage)
        
        guard  let subreddit = subreddit,
            let url = RedditController.shared.getSubredditURL(forPermalink: subreddit.permalink)
        else {
            return
        }
        
        webView.loadRequest(URLRequest(url: url))

    }
    
    private func updateFavoriteIcon(){
        favoriteButton.image = (subreddit?.favorite)! ? ViewConstants.favoriteButtonSelectedImage : ViewConstants.favoriteButtonNormalImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func favoriteButtonWasPressed(_ sender: UIBarButtonItem) {
        subreddit?.favorite = !(subreddit?.favorite)!
        updateFavoriteIcon()
    }


}
