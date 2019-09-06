//
//  SearchViewController.swift
//  sendbird_app
//
//  Created by mac on 05/09/2019.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    private var searchedBookCount : Int = 0
    private var searchedBookLists : [[String : Any]]?
    private var currentPage : Int = 0
    private var searchKeyword : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 150
        self.searchBar.delegate = self
        
    }
    
    func getBooksLists(_ keyWord : String) {
        HttpConnection.getInstance.getBookList(type: REQUEST_TYPE.SEARCH, parameter : keyWord ,completion:  { (_ result, _ responseCode, _ json) in
            
            switch responseCode {
                
            case 200..<300 :
                if let json = json, json["books"] is [[String : Any]] {
                    
                    if let countString = json["total"] as? String, let count = Int(countString) {
                        NSLog("sendBird : Total count :: \(count)")
                        self.searchedBookCount = count
                    }
                    if let currentPage = json["page"] as? String, let pageNumber = Int(currentPage) {
                        self.currentPage = pageNumber
                    }
                    
                    if self.currentPage == 1 {
                        self.searchedBookLists = json["books"] as? [[String : Any]]
                    }
                    else {
                        self.searchedBookLists! += json["books"] as! [[String:Any]]
                        
                    }
                    
                    NSLog("sendBird : ( current : total ) -> ( \(self.currentPage) : \(self.searchedBookCount/10 + 1) )")
                    
                    if (self.searchedBookCount/10 + 1 ) != self.currentPage {
                        let newKeyWord = "\(self.searchKeyword)/\(self.currentPage+1)"
                        self.getBooksLists(newKeyWord)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.rowHeight = 150
                        if self.currentPage % 2 == 1 {
                            NSLog("sendBird : Refresh tableView per even number of page")
                            self.tableView.reloadData()
                        }
                    }
                }
            default:
                NSLog("sendBird : ERROR :: failed to connect to network. please check your network state")
            }
        })
        
    }
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let keyWord = self.searchBar.text {
            
            NSLog("sendBird : now seartching... - \(keyWord)")
            self.view.endEditing(true)
            self.searchKeyword = keyWord
            self.getBooksLists(keyWord)
        }
    }
    
}

extension SearchViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! BookCell
        guard let isbn = cell.isbn.text else {
            return
        }
        NSLog("sendBird : row - \(indexPath.row) selected, isbn \(isbn)")
        BookPresenter.getInstance.showUpDetailOfBook(isbn : isbn)
    }
}
extension SearchViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchedBookCount / 10 + 1) > currentPage {
            return currentPage * 10
        }
        return searchedBookCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        guard let bookLists = searchedBookLists else {
            return cell
        }
        let book = bookLists[indexPath.row]
        
        
        if let url = book["image"] as? String , let fileUrl = URL(string: url) {
            
            if let cashedImage = Storage.getInstance.checkHasCashe(url: url) {
                cell.bookImage.image = UIImage(data: cashedImage as Data)
            }
            else {
                HttpConnection.getInstance.getSearchImageFromUrlQ.async {
                    guard let imageData = NSData(contentsOf: fileUrl) else {
                        NSLog("sendBrid : ERROR :: Can't get image from url...")
                        return
                    }
                    Storage.getInstance.addImageCashe(url, imageData as Data)
                    DispatchQueue.main.async {
                        cell.bookImage.image = UIImage(data: imageData as Data)
                    }
                }
            }
            
            
        }
        cell.title.text = book["title"] as? String
        cell.isbn.text = book["isbn13"] as? String
        cell.price.text = book["price"] as? String
        cell.subTitle.text = book["subtitle"] as? String
        
        return cell
    }
}

