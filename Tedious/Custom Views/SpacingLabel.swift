//
//  SpacingLabel.swift
//  TediousProvider
//
//  Created by Nguyen Chi Dung on 4/27/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

class SpacingLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "text")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateAttributedText()
    }
    
    @IBInspectable
    var letterSpace: CGFloat = 1.0 {
        didSet {
            updateAttributedText()
        }
    }
    
    func updateAttributedText() {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        
        attributedString.addAttribute(NSAttributedStringKey.kern,
                                      value: letterSpace,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        attributedText = attributedString
    }
}
