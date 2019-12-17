//
//  Animations.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 18.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation

    init(animation: @escaping Animation) {
        self.animation = animation
    }
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else { return }
        animation(cell, indexPath, tableView)
        hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
    }
}

enum Animations {
    static func slideIn(duration: TimeInterval, delay: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
            UIView.animate(
                withDuration: duration,
                delay: delay * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
}
