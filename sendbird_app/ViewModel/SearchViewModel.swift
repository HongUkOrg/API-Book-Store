//
//  SearchViewModel.swift
//  sendbird_app
//
//  Created by David Park on 2019/10/28.
//  Copyright © 2019 David Park. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    var books : BehaviorRelay<[BookModel]> = BehaviorRelay(value:[])
    var searchingWord : BehaviorRelay<String> = BehaviorRelay(value: "")
    var searchedBook = SearchedBook()
    var disposeBag = DisposeBag()
    
    func searchTextChanged(_ words : String){
        
        print("searched : \(words)")
        searchingWord.accept(words)
        searchedBook.getBookListsWithWords(words)
            .asObservable()
            .subscribe(
                onNext: { result in
                    self.books.accept(result)
            },
                onError: { err in
                    print("error!!\(err.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    func refereshBook(_ row : Int){
        if row != searchedBook.getBookModels().count-1 {
            return
        }
        
//        searchedBook.getBookListsWithWords(searchingWord.value, <#T##page: Int##Int#>)
        print("refreshed")

    }
    
    
}
