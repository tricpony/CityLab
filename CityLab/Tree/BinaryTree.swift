//
//  BinaryTree.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

enum TraverseDirection {
    case left
    case right
    case all
}

enum BinaryTree<T: SearchAble> {
    
    case empty
    indirect case node(BinaryTree<T>, T, BinaryTree<T>)
    
    static func growTree(fromValues: [T]) -> BinaryTree<T>? {
        var tree: BinaryTree<T> = .empty

        for nodeValue in fromValues {
            tree.insert(newValue: nodeValue)
        }
        
        return tree
    }
    
    var nodeValue: T? {
        switch self {
        case let .node(_, value, _):
            return value
        case .empty:
            return nil
        }
    }
    
    var count: Int {
        switch self {
        case let .node(left, _, right):
            return left.count + 1 + right.count
        case .empty:
            return 0
        }
    }
    
    func nodeChild(whichOne: TraverseDirection) -> BinaryTree? {
        switch self {
        case let .node(left, _, right):
            
            switch whichOne {
            case .left:
                return left
            case .right:
                return right
            default:
                return self
            }

        case .empty:
            return self
        }
    }
    
    private func newTreeWithInsertedValue(newValue: T) -> BinaryTree {
        switch self {
        // 1
        case .empty:
            return .node(.empty, newValue, .empty)
        // 2
        case let .node(left, value, right):
            if newValue < value {
                return .node(left.newTreeWithInsertedValue(newValue: newValue), value, right)
            } else {
                return .node(left, value, right.newTreeWithInsertedValue(newValue: newValue))
            }
        }
    }
    
    mutating func insert(newValue: T) {
        self = newTreeWithInsertedValue(newValue: newValue)
    }
    
    func traverseInOrder(process: (T) -> ()) {
        switch self {
        // 1
        case .empty:
            return
        // 2
        case let .node(left, value, right):
            left.traverseInOrder(process: process)
            process(value)
            right.traverseInOrder(process: process)
        }
    }
    
    func traversePreOrder( process: (T) -> ()) {
        switch self {
        case .empty:
            return
        case let .node(left, value, right):
            process(value)
            left.traversePreOrder(process: process)
            right.traversePreOrder(process: process)
        }
    }
    
    func traversePostOrder( process: (T) -> ()) {
        switch self {
        case .empty:
            return
        case let .node(left, value, right):
            left.traversePostOrder(process: process)
            right.traversePostOrder(process: process)
            process(value)
        }
    }
    
    func search(searchValue: String) -> BinaryTree? {
        switch self {
        case .empty:
            return nil
        case let .node(left, value, right):
            // 1
            if searchValue == value.searchValue {
                return self
            }
            
            // 2
            if searchValue < value.searchValue {
                return left.search(searchValue: searchValue)
            } else {
                return right.search(searchValue: searchValue)
            }
        }
    }
    
    func searchPrefix(searchValue: String) -> BinaryTree? {
        switch self {
        case .empty:
            return nil
        case let .node(left, value, right):
            // 1
            if value.searchValue.startsWith(searchValue) {
                return self
            }
            
            // 2
            if searchValue < value.searchValue {
                return left.searchPrefix(searchValue: searchValue)
            } else {
                return right.searchPrefix(searchValue: searchValue)
            }
        }
    }

}

extension BinaryTree: CustomStringConvertible {
    var description: String {
        switch self {
        case let .node(left, value, right):
            return "value: \(value), left = [" + left.description + "], right = [" + right.description + "]"
        case .empty:
            return ""
        }
    }
}
