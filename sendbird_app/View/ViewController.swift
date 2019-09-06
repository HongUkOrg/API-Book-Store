//
//  ViewController.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/05.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    private var retryCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDataLoaded()
    }

    func checkDataLoaded() {
        
        NSLog("sendBird : now checking if data is loaded or not")
        
        if Storage.getInstance.bookList != nil {
            
            NSLog("sendBird : get data... completed!")
            NSLog("sendBird : move to main view")
            
            self.performSegue(withIdentifier: "toMain", sender: self)
            return
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                
                NSLog("sendBird : retrying to get resource from network.. \(self.retryCount) / 20")
                if self.retryCount > 20 {
                    return
                }
                self.retryCount += 1
                self.checkDataLoaded()
            }
        }
        
    }

}

