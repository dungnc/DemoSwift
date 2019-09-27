//
//  ScrollViewWithButtons.swift
//  Dating Prototype
//
//  Created by Nguyen Chi Dung on 11/4/17.
//  Copyright © 2017 Alpha Codex UAB. All rights reserved.
//

import UIKit

class ScrollViewWithButtons: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

class CollectionViewWithButtons: UICollectionView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

class TableViewWithButtons: UITableView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
