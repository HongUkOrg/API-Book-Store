//
//  BookModel.swift
//  sendbird_app
//
//  Created by David Park on 2019/10/28.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class BookModel: NSObject {

    var title : String?
    var image : String?
    var isbn13 : String?
    var price : String?
    var subtitle : String?
    var url : String?
    
    init(title : String, image : String, isbn13 : String, price : String, subtitle : String, url : String){
        self.title = title
        self.image = image
        self.isbn13 = isbn13
        self.price = price
        self.subtitle = subtitle
        self.url = url
    }
    
}
