//
//  StringExt.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

extension String {

    func startsWith(_ prefix: String) -> Bool {
        return lowercased().hasPrefix(prefix.lowercased())
    }

}
