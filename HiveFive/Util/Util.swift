//
//  Util.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/4/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

public class Utils {
    
    public static func loadFile(name: String, extension ext: String) -> String? {
        let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        return String(data: data!, encoding: .utf8)
    }
    
    public static func loadJSON(from fileName: String) -> Any? {
        let path = Bundle.main.path(forResource: fileName, ofType: "json", inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        print(jsonObj ?? "not valid")
        return jsonObj
    }
    
    public static func loadFrom(url: String, completion: @escaping HtmlCompletionHandler) {
        if let url = URL(string: url) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            }
            dataTask.resume()
        }
    }
    
    public static func saveToUserDefault(obj: Any, key: String) {
        UserDefaults.standard.set(obj, forKey: key)
        print("saved: \(obj) with key: \(key)")
    }
    
    public static func retrieveFromUserDefualt(key: String) -> Any? {
        let obj = UserDefaults.standard.object(forKey: key)
        print("retrieved \(String(describing: obj)) for key: \(key)")
        return obj
    }
    
    public typealias HtmlCompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
}
