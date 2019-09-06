//
//  DetailViewController.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/06.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
   
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var author_publisher_year: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var isbn10: UILabel!
    @IBOutlet weak var isbn13: UILabel!
    @IBOutlet weak var page: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var price: UILabel!
    
    internal var isbn : String?
    private var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
        // Do any additional setup after loading the view.
    }
    
    
    func loadDetails() {
        if let isbn = isbn {
            HttpConnection.getInstance.getBookList(type: REQUEST_TYPE.DETAIL, parameter: isbn, completion: { (_ result, _ responseCode, _ json) in
                
                switch responseCode {
                    
                case 200..<300 :
                    if let json = json {
                        
                        self.url = json["url"] as? String
                        
                        if let url = json["image"] as? String, let fileUrl = URL(string: url) {
                            if let cashedImage = Storage.getInstance.checkHasCashe(url: url) {
                                
                                DispatchQueue.main.async {
                                    self.bookImageView.image = UIImage(data: cashedImage as Data)
                                }
                            }
                            else {
                                HttpConnection.getInstance.getNewImageFromUrlQ.async {
                                    if let imageData = NSData(contentsOf: fileUrl) {
                                        Storage.getInstance.addImageCashe(url, imageData as Data)
                                        DispatchQueue.main.async {
                                            self.bookImageView.image = UIImage(data: imageData as Data)
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        DispatchQueue.main.async {
                            
                            self.titleLabel.text            = json["title"] as? String
                            self.subTitleLabel.text         = json["subtitle"] as? String
                            self.page.text                  = json["page"] as? String
                            self.language.text              = json["language"] as? String
                            self.descriptionLabel.text      = json["desc"] as? String
                            self.price.text                 = json["price"] as? String
                            
                            if let isbn10 = json["isbn10"] as? String {
                                self.isbn10.text = "isbn 10 : \(isbn10)"
                            }
                            if let isbn13 = json["isbn13"] as? String {
                                self.isbn13.text = "isbn 13 : \(isbn13)"
                            }
                            if let rating = json["rating"] as? String {
                                self.rating.text = "rating : \(rating)/5"
                            }
                            if let author = json["authors"] as? String, let publisher = json["publisher"] as? String , let year = json["year"] as? String {
                                self.author_publisher_year.text = "\(author), \(publisher), \(year)"
                            }
                            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: 500)

                        }
                        
                    }
                default:
                    NSLog("sendBird : ERROR :: failed to connect to network. please check your network state")
                }
            })
        }
    }


    @IBAction func goToWebBtnClicked(_ sender: Any) {
        if let url = URL(string: self.url!),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
        
    }
    
    @IBAction func dismissBtnClicekd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func memoBtnClicked(_ sender: Any) {
        
        if Storage.getInstance.checkHasMemo(self.isbn!) {
            showMemoContentAlert()
        }
        else {
            showTextFiledAlert()
        }
        
    }
    
    func showTextFiledAlert() {
        let alertController = UIAlertController(title: "Memo", message: "Input your text", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            if let inputText = alertController.textFields?[0].text {
                Storage.getInstance.setPref(key: self.isbn!, value: inputText)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addTextField()
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMemoContentAlert() {
        let alertController = UIAlertController(title: "Memo", message: "Message", preferredStyle: .alert)
        
        alertController.message = Storage.getInstance.getPrefString(key: self.isbn!, defValue: "")
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("sendBird : Cancel Clicked")
        }
        let okAction = UIAlertAction(title: "Edit", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("sendBird : Edit Pressed")
            self.showTextFiledAlert()
        
        }
       
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
