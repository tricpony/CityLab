//
//  City.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

protocol SearchAble: Comparable {
    var searchValue :String { get }
}

struct City: SearchAble, Codable {
    
    var name = "Not Found"
    var country = "Not Found"
    var id = 0
    var lat: Double = 0
    var lon: Double = 0
    var searchValue: String {
        return self.name
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case country
        case id = "_id"
        case coord

        enum CoordKeys: String, CodingKey {
            case lon
            case lat
        }
        
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.id = try container.decode(Int.self, forKey: .id)

        let coordContainer = try container.nestedContainer(keyedBy: CodingKeys.CoordKeys.self, forKey: .coord)
        self.lat = try coordContainer.decode(Double.self, forKey: .lat)
        self.lon = try coordContainer.decode(Double.self, forKey: .lon)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .name)
        try container.encode(id, forKey: .id)
    }
    
    // MARK: - Comparable

    static func == (lhs: City, rhs: City) -> Bool {
        return (lhs.name == rhs.name) && (lhs.country == rhs.country)
    }
    
    static func < (lhs: City, rhs: City) -> Bool {
        if lhs.name != rhs.name {
            return lhs.name < rhs.name
        }else{
            return lhs.country < rhs.country
        }
    }
    
}
