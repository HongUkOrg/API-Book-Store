//
//  NewViewController.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/05.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class NewViewController: UIViewController , UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var books : [Book] = []
    private var urls : [String]?
    private var bookCount : Int?
    private var bookLists : [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        guard let bookLists = Storage.getInstance.bookList, let bookCount = Storage.getInstance.bookCount else {
            NSLog("sendBird : ERROR :: Invalid book lists")
            return
        }
        
        books = createSlides(length: bookCount, bookLists: bookLists)
        setUpSlideScrollView(slides: books)
        
        pageControl.numberOfPages = bookCount
        pageControl.currentPage = 0
    }
    
    func createSlides(length : Int, bookLists : [[String:Any]]) -> [Book] {
        
        let bundle = Bundle.main
        var arr : [Book] = []
        
        for i in 0..<length {
            let newSlide : Book = bundle.loadNibNamed("Book", owner: self, options: nil)?.first as! Book
            
            let book = bookLists[i]
            newSlide.imageUrl       = book["image"] as? String
            newSlide.titleString    = book["title"] as? String
            newSlide.subTitleString = book["subtitle"] as? String
            newSlide.isbnString     = book["isbn13"]  as? String
            newSlide.priceString    = book["price"] as? String
            newSlide.awakeFromNib()
            arr.append(newSlide)
        }
        
        
        return arr
    }
    
    func setUpSlideScrollView(slides : [Book]){
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: 1.0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        
        let index : Int = ceil(percentOffset.x * CGFloat(books.count-1))
        let offset : CGFloat = 1.0/CGFloat(books.count-1)
        let ratio : CGFloat = offset * CGFloat(index)
        
        if index <= 0 || index > books.count-1 {
            return
        }
        
        
        books[index-1].imageView.transform = CGAffineTransform(scaleX: (ratio-percentOffset.x)/offset, y: (ratio-percentOffset.x)/offset)
        books[index].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/ratio, y: percentOffset.x/ratio)
        
        
    }
    
    
    private func ceil(_ input : CGFloat) -> Int {
        if input == 0 {
            return 0
        }
        else {
            return Int(input) + 1
        }
    }
    


}


