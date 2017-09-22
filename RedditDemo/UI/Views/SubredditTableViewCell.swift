//
//  SubredditTableViewCell.swift
//  RedditDemo
//
//  Created by Egidijus Ambrazas on 15/09/2017.
//  Copyright © 2017 Egidijus Ambrazas. All rights reserved.
//

import UIKit

class SubredditTableViewCell: UITableViewCell {

    struct ViewConstants {
        static let favoriteButtonSelectedImage = #imageLiteral(resourceName: "icons8-Star Filled-50")
        static let favoriteButtonNormalImage = #imageLiteral(resourceName: "icons8-Star-50")
    }
    
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var favorite:Bool = false {
        didSet {
            favoriteIcon.image =  favorite ? ViewConstants.favoriteButtonSelectedImage : ViewConstants.favoriteButtonNormalImage
        }
    }
    
    override func prepareForReuse() {
        favorite = false
        thumbnailView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
