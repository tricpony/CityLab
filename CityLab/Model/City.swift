//
//  City.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

protocol SearchAble {
    var searchValue :String { get }
}

struct City: Comparable {
    var name = "Not Found"
    var country = "Not Found"
    var id = "Not Found"
    var lat = 0
    var lon = 0
    var searchValue = "Not Found"
    
    init(info: Dictionary<String,Any>) {
        
        if let localName = info["name"] as? String {
            name = localName
            searchValue = localName
            country = (info["country"] as? String)!
            id = (info["_id"] as? String)!
            
            if let coord = info["coord"] as? Dictionary<String,Int> {
                lat = coord["lat"]!
                lon = coord["lon"]!
            }
        }
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.name.startsWith(rhs.name)
    }
    
    static func < (lhs: City, rhs: City) -> Bool {
        return lhs.name < rhs.name
    }
    
}
