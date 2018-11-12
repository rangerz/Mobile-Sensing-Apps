//
//  RequestsModel.swift
//  HTTPSwiftExample
//
//  Created by Alejandro Henkel on 11/11/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//
let SERVER_URL = "http://192.168.1.69:8000"
//let SERVER_URL = "http://192.168.0.21:8000"
let COOKIE_SECRET = "eric_cookie=61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o"

import UIKit

class JSONUtilities: NSObject {
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                                 options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
}
