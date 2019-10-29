//
//  HttpConnection.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/05.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

internal enum REQUEST_TYPE {
    case NEW, SEARCH, DETAIL
}

class HttpConnection: NSObject {
    
    static let getInstance : HttpConnection = HttpConnection()
    let getNewImageFromUrlQ = DispatchQueue(label : "_getImageFromUrl_New", attributes: .concurrent)
    let getSearchImageFromUrlQ = DispatchQueue(label : "_getImageFromUrl_Search", attributes: .concurrent)


    func getBookList(type : REQUEST_TYPE, parameter : String = "", completion : @escaping (_ result : Bool, _ responseCode : Int, _ json :[String : Any]?)->()) {
        
        DispatchQueue.main.async {
            
            let url : URL?
            
            switch type {
            case .NEW :
                url = URL(string : "https://api.itbook.store/1.0/new")
            case .SEARCH :
                let urlString : String = "https://api.itbook.store/1.0/search/" + parameter
                url = URL(string : urlString)
            case .DETAIL :
                let urlString : String = "https://api.itbook.store/1.0/books/" + parameter
                url = URL(string : urlString)
            }
            guard let validUrl = url else {
                return
            }
            
            var request = URLRequest(url: validUrl)
            request.httpMethod = "GET"
            request.timeoutInterval = 60
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let response = response, error == nil else {
                        completion(false, -1, nil)
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if httpResponse.statusCode >= 200, httpResponse.statusCode < 300 {
                            
                            
                            if let data = data, let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) {
                                
                                if let responseJSON = responseJSON as? [String: Any], responseJSON.isEmpty == false {
                                    completion(true, httpResponse.statusCode, responseJSON)
                                }
                                    
                                else {
                                    completion(true, httpResponse.statusCode, nil)
                                }
                            }
                            else {
                                completion(true, httpResponse.statusCode, nil)
                            }
                        }
                        else {
                            completion(false, httpResponse.statusCode , nil)
                        }
                    }
                    else {
                        completion(false, -1 , nil)
                    }
                
            }
            task.resume()
            
        }
        
        
    }
    
}
