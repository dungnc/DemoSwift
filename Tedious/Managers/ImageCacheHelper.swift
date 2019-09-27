//
//  ImageCacheManager.swift
//  TediousCustomer
//
//  Created by Nguyen Chi Dung on 4/26/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage

class ImageCacheManager {

    static open let rx_currentUserPhoto: Variable<UIImage?> = Variable(ImageCacheManager.cachedPhotoForCurrentUser())

    static func loadPhotoForCurrentUser() {
        guard let user: TDUser = Customer.current ?? Provider.current, let photoUrl = user.photoUrl else {
            return
        }
        Alamofire.request(photoUrl).responseImage { response in
            if let image = response.result.value {
                ImageCacheManager.cachePhoto(forUser: user, image: image)
            }
        }
    }
    
    static func cachedPhotoForCurrentUser() -> UIImage? {
        if let user: TDUser = Customer.current ?? Provider.current {
            if let imageData = UserDefaults.standard.data(forKey: user.id) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    static func cachePhoto(forUser user: TDUser, image: UIImage) {
        UserDefaults.standard.setValue(UIImageJPEGRepresentation(image, 1.0), forKey: user.id)
        UserDefaults.standard.synchronize()
        rx_currentUserPhoto.value = image
    }
    
    static func removeCachedPhoto(forUserId userId: String) {
        UserDefaults.standard.removeObject(forKey: userId)
        UserDefaults.standard.synchronize()
        rx_currentUserPhoto.value = nil
    }
}
