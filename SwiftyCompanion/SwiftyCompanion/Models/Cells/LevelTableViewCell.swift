//
//  LevelTableViewCell.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 12.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var veryBackgroundLabel: UIView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    @IBOutlet weak var backgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightInsetConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        levelLabel.font = UIFont.preferredFont(forTextStyle: .body)
        levelLabel.adjustsFontForContentSizeCategory = true
        levelLabel.numberOfLines = 1
    }
    
}
