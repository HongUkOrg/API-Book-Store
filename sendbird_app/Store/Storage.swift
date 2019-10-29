//
//  Storage.swift
//  sendbird_app
//
//  Created by David Park on 2019/09/05.
//  Copyright © 2019 David Park. All rights reserved.
//

import UIKit

class Storage: NSObject {

    static let getInstance : Storage = Storage()
    internal var bookList : [[String : Any]]?
    internal var bookCount : Int?
    internal var casheImage : [String:Data] = [String:Data]()
    private var preference : UserDefaults
    
    override init() {
        preference = UserDefaults.standard
        super.init()
    }
    
    
    func getResource() {
        HttpConnection.getInstance.getBookList(type: REQUEST_TYPE.NEW, completion: { (_ result, _ responseCode, _ json) in
            
            switch responseCode {
                
            case 200..<300 :
                if let json = json, json is [String : Any], json["books"] is [[String : Any]] {
                    
                    if let countString = json["total"] as? String, let count = Int(countString) {
                        NSLog("count is \(count)")
                        self.bookCount = count
                    }
                    
                    Storage.getInstance.bookList = json["books"] as? [[String : Any]]
                    NSLog("Vaild Josn format")
                }
                NSLog("get type : \(type(of: json))")
            default:
                ()
            }
        })
    }
    
    func checkHasCashe(url : String ) -> Data?{
        if let imageData = casheImage[url] {
            return imageData
        }
        return nil
    }
    func addImageCashe(_ url : String, _ imageData : Data) {
        casheImage[url] = imageData
    }
    
    
    func checkHasMemo(_ isbn : String) -> Bool {
        if getPrefString(key: isbn, defValue: "") != "" {
            return true
        }
        else {
            return false
        }
    }
    
    func setPref(key : String, value : String){
        
        let preferences = UserDefaults.standard
        
        preferences.set(value, forKey: key)
        preferences.synchronize()
    }
    func getPrefString(key : String, defValue : String) -> String? {
        let preferences = UserDefaults.standard
        if containsKey(existKey: key), (preferences.object(forKey: key) as? String) != nil {
            return preferences.string(forKey: key)
        }
        else {
            return defValue
        }
    }
    func containsKey(existKey : String) -> Bool {
        
        let preferences = UserDefaults.standard
        return preferences.object(forKey: existKey) != nil
    }
}
