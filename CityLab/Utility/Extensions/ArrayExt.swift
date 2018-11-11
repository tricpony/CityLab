//
//  ArrayExt.swift
//  CityLab
//
//  Created by aarthur on 11/10/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

extension Array where Element: SearchAble {

    func binarySearch(searchTerm: String) -> Int? {
        
        if self.isEmpty { return nil }
        var lowerIndex = 0;
        var upperIndex = self.count - 1

        while true {
            let mid = (lowerIndex + upperIndex)/2
            let searchableValue = self[mid].searchValue
            
            print("Searching: \(searchableValue) to match \(searchTerm)")
            
            if self[mid].searchValue == searchTerm {
                return mid
            } else if lowerIndex > upperIndex {
                return nil
            } else {
                if self[mid].searchValue > searchTerm {
                    upperIndex = mid - 1
                } else {
                    lowerIndex = mid + 1
                }
            }
        }
    }
    
    func binaryPrefixSearch(searchTerm: String) -> Int? {
        
        if self.isEmpty { return nil }
        var lowerIndex = 0;
        var upperIndex = self.count - 1
        
        while true {
            let mid = (lowerIndex + upperIndex)/2
            
            if self[mid].searchValue.startsWith(searchTerm) {
                return mid
            } else if lowerIndex > upperIndex {
                return nil
            } else {
                if self[mid].searchValue > searchTerm {
                    upperIndex = mid - 1
                } else {
                    lowerIndex = mid + 1
                }
            }
        }
    }
    

    /*
     Here we want to snip off trailing items not matching searchTerm to shrink the result set
     then the caller must remove any remaining non-matching items in a linear way
     */
    func binaryPrefixSearchOutOfRange(searchTerm: String) -> Int {
        
        if self.isEmpty { return 0 }
        var lowerIndex = 0;
        var upperIndex = self.count - 1

        while true {
            let mid = (lowerIndex + upperIndex)/2

            if !self[mid].searchValue.startsWith(searchTerm) {
                return mid
            } else if lowerIndex > upperIndex {
                return upperIndex
            } else {
                if self[mid].searchValue.startsWith(searchTerm) {
                    lowerIndex = mid + 1
                } else {
                    upperIndex = mid - 1
                }
            }
        }
    }
    
}

