//
//  Loading.swift
//  Scrath
//
//  Created by Meagan Sanchez on 6/9/16.
//  Copyright © 2016 Skyla157. All rights reserved.
//

import UIKit

class LoadingOverlay {
    var overlayView = UIView()
    var activityIndictator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    func showOverlay(view: UIView) {
        overlayView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.5
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 5

        activityIndictator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndictator.activityIndicatorViewStyle = .whiteLarge
        activityIndictator.hidesWhenStopped = true
        activityIndictator.center = view.center
        
        overlayView.addSubview(activityIndictator)
        view.addSubview(overlayView)
        
        activityIndictator.startAnimating()
    }
    
    func hideOverlay() {
        activityIndictator.stopAnimating()
        overlayView.removeFromSuperview()
    }    
}


