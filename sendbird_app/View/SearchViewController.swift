//
//  SearchViewController.swift
//  sendbird_app
//
//  Created by mac on 05/09/2019.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    private var searchedBookCount : Int = 0
    private var searchedBookLists : [[String : Any]]?
    private var currentPage : Int = 0
    private var searchKeyword : String = ""
    
    private var viewModel = SearchViewModel()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
        self.tableView.rowHeight = 150
        
        self.setup()
    }
    
    func setup(){
        
        // searchBar text binding
        self.searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { text in
                self.viewModel.searchTextChanged(text)
                
            })
            .disposed(by: disposeBag)
        
        // tableview + data binding
        self.viewModel.books.bind(to:
        self.tableView.rx.items){ tableView, row, data in
            
            self.viewModel.refereshBook(row)
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
            
            cell.title.text = data.title
            cell.isbn.text = data.isbn13
            cell.price.text = data.price
            cell.subTitle.text = data.subtitle
            
            Observable.just(data.image!)
                .map{ URL(string: $0) }
                .filter{ $0 != nil }
                .map { URLRequest(url: $0!)}
                .subscribe(onNext: { request in
                    URLSession.shared.rx.data(request: request)
                        .map { data in UIImage(data: data) }
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { image in
                        cell.bookImage.image = image
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by : self.disposeBag)
            return cell
        }
        .disposed(by: disposeBag)
        
        
        // table row selected
        tableView.rx.itemSelected
            .asObservable()
            .subscribe(onNext: { indexPath in
                let cell = self.tableView.cellForRow(at: indexPath) as! BookCell
                guard let isbn = cell.isbn.text else {
                    return
                }
                BookPresenter.getInstance.showUpDetailOfBook(isbn : isbn)
            })
            .disposed(by: disposeBag)
                
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

