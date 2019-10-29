//
//  SearchedBook.swift
//  sendbird_app
//
//  Created by David Park on 2019/10/28.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchedBook: NSObject {
    
    
    var bookModels : [BookModel] = []
    var pageCount : Int = 1
    
    func getBookListsWithWords(_ keyWord : String, _ page : Int = 1) -> Observable<[BookModel]> {
    
        var urlString = "https://api.itbook.store/1.0/search/" + keyWord
        
        if page != 1 {
            urlString = "\(urlString)/\(page)"
        }
        guard let url = URL(string: urlString) else {
            print("invalid url")
            return Observable.just([])
        }
        return URLSession.shared.rx.json(url: url)
            .retry(3)
            .map(parse)
        
    }
    
    func parse(json : Any) -> [BookModel] {
        
        print("parse!!")
        if let json = json as? [String:Any], let books = json["books"] as? [[String:Any]] {
            print(json.description)
            bookModels = []
            for book in books {
                guard let title = book["title"] as? String,
                let image = book["image"] as? String,
                let isbn13 = book["isbn13"] as? String,
                let price = book["price"] as? String,
                let subtitle = book["subtitle"] as? String,
                let url = book["url"] as? String else {
                    continue
                }
                let tempBookModel = BookModel(title: title, image: image, isbn13: isbn13, price: price, subtitle: subtitle, url: url)
                bookModels.append(tempBookModel)
            }
            return bookModels
        }
        else {
            return []
        }
    }
    
    func addBookModel(_ book : BookModel){
        bookModels.append(book)
    }
    
    func getBookModels() -> [BookModel] {
        return bookModels
    }
}
