//
//  PostsViewController.swift
//  RedditDemo
//
//  Created by Egidijus Ambrazas on 14/09/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit
import SDWebImage

class SubredditsViewController: UIViewController {
    
    struct ViewConstants {
        static let favoritesTitle = "Favorites"
        static let subredditCellNib = "SubredditTableViewCell"
        static let subredditCellIdentifier = "SubredditTableViewCellIdentifier"
        static let notLoadedSubredditCellIdentifier = "NotLoadedSubredditTableViewCellIdentifier"
        
        static let openWebVIewSegue = "openWebVIewSegue"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var subredditsArray = [Subreddit]()
    var filteredSubreddits = [Subreddit]()
    var showingOnlyFavorites = false
    var searchIsEnabled = false
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private let lastIndexPatch: IndexPath? = nil
    private let searchController = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        //...
        if showingOnlyFavorites {
            self.navigationItem.title = ViewConstants.favoritesTitle
        } else {
            fetchSureddits(after: "")
            self.navigationItem.title = RedditController.shared.getListTitle()
            
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            tableView.tableHeaderView = searchController.searchBar
        }

        
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

        
        tableView.delegate = self
        tableView.dataSource = self

        let subredditCellNib = UINib(nibName: ViewConstants.subredditCellNib, bundle: nil)
        tableView.register(subredditCellNib, forCellReuseIdentifier: ViewConstants.subredditCellIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if showingOnlyFavorites{
            subredditsArray = RedditController.shared.allLoadedSubreddits.filter({ $0.favorite })
        }
        
        tableView.reloadData()
    }
    
    
    func fetchSureddits(after id:String) {
        RedditController.shared.fetchSureddits(after: id) { (results) in
            switch results {
            case .failure(let error) :
                print(error)
                return
            case .success(let fetchedSubreddits) :
                self.subredditsArray.append(contentsOf: fetchedSubreddits)
                if self.lastIndexPatch != nil{
                    self.tableView.reloadSections([1], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            case .inprogress :
                return
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ViewConstants.openWebVIewSegue {
            if let webviewViewController = segue.destination as? SubredditPageViewController,
                let subreddit = sender as? Subreddit {
                webviewViewController.subreddit = subreddit
                
            }
        }
    }
    
    // MARK: Search releated methods
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSubreddits = subredditsArray.filter({( sureddit : Subreddit) -> Bool in
            return sureddit.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}

extension SubredditsViewController:  UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subreddit: Subreddit
        if isFiltering(){
            subreddit = filteredSubreddits[indexPath.row]
        } else {
            subreddit = subredditsArray[indexPath.row]
        }
        performSegue(withIdentifier: ViewConstants.openWebVIewSegue, sender: subreddit)
    }
}

extension SubredditsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredSubreddits.count
        } else{
            return subredditsArray.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewConstants.subredditCellIdentifier) as! SubredditTableViewCell

        let subreddit: Subreddit
        if isFiltering() {
            subreddit = filteredSubreddits[indexPath.row]
        } else {
            subreddit = subredditsArray[indexPath.row]
        }
        
        cell.titleLabel?.text = subreddit.title
        
        if let thumbnailUrl = subreddit.thumbnailUrl {
             cell.thumbnailView.sd_setImage(with: thumbnailUrl, placeholderImage: UIImage())
        }
        cell.commentsLabel?.text = "\(subreddit.comments) comments"
        cell.favorite = subreddit.favorite
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //https://stackoverflow.com/questions/42457343/add-a-activityindicator-to-the-bottom-of-uitableview-while-loading
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if showingOnlyFavorites || isFiltering() {
            self.tableView.tableFooterView = UIView()
            return
        }
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.tableView.tableFooterView = self.spinner
            self.tableView.tableFooterView?.isHidden = false
            
            fetchSureddits(after: subredditsArray[lastRowIndex].id)
        }
    }
}


extension SubredditsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

