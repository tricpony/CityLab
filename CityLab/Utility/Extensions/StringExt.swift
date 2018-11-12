//
//  StringExt.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

extension String {

    /*
        Made public to make it visible inside unit test cases
    */
    public func startsWith(_ prefix: String) -> Bool {
        return lowercased().hasPrefix(prefix.lowercased())
    }

}
