//
//  Book.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/05.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class Book: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var isbn: UILabel!
    
    internal var imageUrl : String?
    internal var titleString : String?
    internal var subTitleString : String?
    internal var priceString : String?
    internal var isbnString : String?
    
    override func awakeFromNib() {
        
        if let titleString = titleString, let subTitleString = subTitleString
            , let priceString = priceString, let isbnString = isbnString {
            self.title.text = titleString
            self.subTitle.text = subTitleString
            self.price.text = priceString
            self.isbn.text = "isbn : " + isbnString
        }
        
        if let url = imageUrl, let fileUrl = URL(string: url) {
            
            if let cashedImage = Storage.getInstance.checkHasCashe(url: url) {
                self.imageView.image = UIImage(data: cashedImage as Data)
                return
            }
            
            HttpConnection.getInstance.getNewImageFromUrlQ.async {
                guard let imageData = NSData(contentsOf: fileUrl) else {
                    NSLog("sendBird : ERROR :: Can't get image from url...")
                    return
                }
                Storage.getInstance.addImageCashe(url, imageData as Data)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData as Data)
                }
            }
            
        }
        
      
    }
    
    @IBAction func detailBtnClicekd(_ sender: Any) {
        
        NSLog("sendBird : clicked book :: ibsn - \(isbnString!)")
        BookPresenter.getInstance.showUpDetailOfBook(isbn: isbnString!)
    }
    

}
