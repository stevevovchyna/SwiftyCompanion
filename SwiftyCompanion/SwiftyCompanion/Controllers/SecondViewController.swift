//
//  SecondViewController.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 11.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import UIKit
import SwiftyJSON

class SecondViewController: UIViewController {
    
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let imageView = UIImageView()

    var userData : JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        tableView.estimatedRowHeight = 50
        tableView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor.darkGray
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "svovchyn")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        specialView.addSubview(imageView)
        

    }
    
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoTableViewCell
        cell.myCellLabel.text = "some random data"
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 200), 400)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
        if scrollView.contentOffset.y < -400 {
            scrollView.contentOffset.y = -400
        }
    }

}
