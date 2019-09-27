//
//  Utils.swift
//  Tedious
//
//  Created by Nguyen Chi Dung on 4/17/18.
//  Copyright © 2018 Tedious. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static func keyboardHeight(fromNotification notification: Notification) -> CGFloat {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.height
        return keyboardHeight
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func setupShadow(forView view: UIView, opacity: Float, radius: CGFloat) {
        view.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = radius
    }
    
    static func adjustStyle(forDoneButton doneButton: UIBarButtonItem) {
        doneButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: K.Font.Bold, size: 20)!,
            NSAttributedStringKey.foregroundColor: UIColor(hex: 0x2192D9)
            ], for: .normal)
        doneButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: K.Font.Bold, size: 20)!,
            NSAttributedStringKey.foregroundColor: UIColor.lightGray
            ], for: .highlighted)
    }
    
    static func showAddPhotoActionSheet(in viewController: UIViewController, completion:  @escaping (_ sourceType: UIImagePickerControllerSourceType) -> ()) {
        let alertController = UIAlertController(title: "Photo",
                                                message: "How to add a photo?",
                                                preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "CAMERA", style: .default) { (_) in
            completion(.camera)
        }
        let galleryAction = UIAlertAction(title: "GALLERY", style: .default) { (_) in
            completion(.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showWeAreNotQuiteThereAlert() {
        let alertController = UIAlertController(title: "We’re not quite there",
                                                message: "We don’t service to your address just yet. We’re expandings soon and can let you know when Tedious arrives.",
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        visibleViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    static func visibleViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return visibleViewController(navigationController.viewControllers.last!)
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return visibleViewController(tabBarController.selectedViewController!)
            }
            
            return visibleViewController(presented)
        }
        return nil
    }
    
    static func durationToString(_ duration: TimeInterval) -> String {
        let minutes = Int(ceil(duration / 60.0))
        let hours = minutes / 60
        var durationString = ""
        if hours > 0 {
            let leftMinutes = minutes % 60
            durationString = "\(hours) Hr, \(leftMinutes) Min"
        } else {
            durationString = "\(minutes) Min"
        }
        return durationString
    }
}

