//
//  BookPresenter.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/06.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class BookPresenter: NSObject {

    static let getInstance : BookPresenter = BookPresenter()
    
    override init() {
        super.init()
    }
    
    func showUpDetailOfBook(isbn : String) {
        
        DispatchQueue.main.async {
            guard let kw = UIApplication.shared.keyWindow, let rootV = kw.rootViewController else {
                return
            }
            
            
            var vc : UIViewController?
            if let presentedV = rootV.presentedViewController {
                vc = presentedV
            }
            else {
                if let topV = UIApplication.shared.topViewController {
                    vc = topV
                }
            }
            
            let bundle = Bundle.main
            let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
            let detailView = storyBoard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
            detailView.isbn = isbn
            detailView.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

            guard let presentView = vc else {
                return
            }
            
            presentView.present(detailView, animated: true, completion: nil)
        }
       
    
    }
}

extension UIApplication{
    var topViewController: UIViewController?{
        
        if keyWindow?.rootViewController == nil{
            return keyWindow?.rootViewController
        }
        
        var pointedViewController = keyWindow?.rootViewController
        
        while  pointedViewController?.presentedViewController != nil {
            switch pointedViewController?.presentedViewController {
            case let navagationController as UINavigationController:
                pointedViewController = navagationController.viewControllers.last
            case let tabBarController as UITabBarController:
                pointedViewController = tabBarController.selectedViewController
            default:
                pointedViewController = pointedViewController?.presentedViewController
            }
        }
        return pointedViewController
        
    }
}
