//
//  JsonUtility.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

struct JsonUtility {
    
    static func parseJSON(_ payload: Data?) -> ([Dictionary<String,Any>]?) {
        guard let dataResponse = payload else {
            return nil
        }

        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
            
            guard let jsonDict = jsonResponse as? [[String: Any]] else {
                return nil
            }
            return jsonDict
            
        } catch let parsingError {
            print("JSON parse error ", parsingError)
        }

        return nil
    }

}
