//
//  Utils.swift
//  SwiftyCompanion
//
//  Created by Steve Vovchyna on 13.12.2019.
//  Copyright © 2019 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

class myLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.layer.cornerRadius = 5
        self.textAlignment = .center
        self.clipsToBounds = true
        self.sizeToFit()
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
}

class DownloadOperation : Operation {
    
    private var task : URLSessionDataTask!
    
    enum OperationState : Int {
        case ready
        case executing
        case finished
    }
    
    private var state : OperationState = .ready {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
  
    init(session: URLSession, dataTaskURLRequest: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
        super.init()
        
        task = session.dataTask(with: dataTaskURLRequest, completionHandler: { [weak self] (data, response, error) in

            if let completionHandler = completionHandler {
                completionHandler(data, response, error)
            }
            self?.state = .finished
        })
    }

    override func start() {
        if self.isCancelled {
            state = .finished
            return
        }
        state = .executing
        self.task.resume()
    }

    override func cancel() {
        super.cancel()
        self.task.cancel()
    }
}
