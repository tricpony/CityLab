//
//  JsonUtility.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

struct JsonUtility<T: Decodable> {
    
    static func parseJSON(_ payload: Data?) -> [T]? {
        
        if payload == nil {
            return nil
        }

        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode([T].self, from: payload!)
            
            return decoded
        } catch {
            print("Failed to decode JSON")
        }

        return nil
    }

}
