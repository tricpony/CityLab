//
//  SearchViewController.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var cityTree: BinaryTree<City>? = nil
    var dataSource = [City]()
    var masterDataSource = [City]()
    var lastSearchTerm = ""
    var isNarrowingSearch = false
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()

        prepareData()
    }
    
    func prepareData() {
        let cityPath = Bundle.main.path(forResource: "cities", ofType: "json")
        let cityUrl = URL.init(fileURLWithPath: cityPath!)
        var cityData :Data? = nil
        
        do {
            cityData = try Data.init(contentsOf: cityUrl)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        if let cities = JsonUtility<City>.parseJSON(cityData) {
            self.dataSource = cities.sorted()
            self.masterDataSource = self.dataSource
            setupSearchController()
        }
    }
    
    func initializeCityTree() {
        let cityPath = Bundle.main.path(forResource: "cities", ofType: "json")
        let cityUrl = URL.init(fileURLWithPath: cityPath!)
        var cityData :Data? = nil
        
        do {
            cityData = try Data.init(contentsOf: cityUrl)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        if let cities = JsonUtility<City>.parseJSON(cityData) {
            self.cityTree = BinaryTree<City>.growTree(fromValues: cities)
        }
        
    }

    func processSearchResults(searchTerm: String) {
        
        func findTerminatingIndex(inArray: Array<City>, startingAt: Int, direction: TraverseDirection) -> Int {
            if startingAt == 0 {return startingAt}
            
            var floatingIndex = startingAt
            var stop = false
            
            if direction == .left {
                while !stop {
                    stop = !inArray[floatingIndex-1].name.startsWith(searchTerm)
                    if !stop {
                        floatingIndex -= 1
                        stop = floatingIndex == 0
                    }
                }
            }else if direction == .right {
                while !stop {
                    stop = inArray[floatingIndex-1].name.startsWith(searchTerm)
                    if !stop {
                        floatingIndex -= 1
                        stop = floatingIndex == 0
                    }
                }
                floatingIndex -= 1
            }

            return floatingIndex
        }
        
        if !isNarrowingSearch {
            self.dataSource = self.masterDataSource
        }
        
        let matchingIndex = self.dataSource.binaryPrefixSearch(searchTerm: searchTerm)
        if let safeIndex = matchingIndex {
            var leadFloatingIndex = safeIndex
            
            leadFloatingIndex = findTerminatingIndex(inArray: self.dataSource, startingAt: safeIndex, direction: .left)

            //now we need to find the end of the matching results
            let slice = self.dataSource[leadFloatingIndex...self.dataSource.count-1]
            var subarray = Array(slice)

            let trailFloatingIndex = subarray.binaryPrefixSearchOutOfRange(searchTerm: searchTerm)
            subarray = Array(subarray[0...trailFloatingIndex])

//            trailFloatingIndex = findTerminatingIndex(inArray: subarray, startingAt: trailFloatingIndex, direction: .right)
            
            self.dataSource = subarray.filter({ (nextCity) -> Bool in
                return nextCity.name.startsWith(searchTerm)
            })
            
//            self.dataSource = Array(subarray[0...trailFloatingIndex])
            self.tableView.reloadData()
        }
        
    }
    
    func processSearchResults(matchingCity: City) {
        
        //        self.dataSource.map { (nextCity) -> Bool in
        //            print("Searching: \(nextCity.name)")
        //
        //            return true
        //        }
        let matchingIndex = self.dataSource.binarySearch(searchTerm: matchingCity.name)
        
        if let safeIndex = matchingIndex {
            var floatingIndex = safeIndex
            var stop = false
            
            while !stop {
                floatingIndex -= 1
                stop = matchingCity.name != self.dataSource[floatingIndex].name
            }
            
            //now we need to find the end of the matching results
            let slice = self.dataSource[floatingIndex...self.dataSource.count-1]
            let subarray = Array(slice)
            
            self.dataSource = subarray.filter({ (nextCity) -> Bool in
                return nextCity.name.startsWith(self.searchController.searchBar.text!)
            })
            self.dataSource.sort()
            self.tableView.reloadData()
        }
        
    }

    func traverseCityTree(atNode: BinaryTree<City>, direction: TraverseDirection = .all) {
        var cityCount = atNode.count
        var primerLoaded = false
        var traverseRoot = atNode
        
        self.dataSource.removeAll()
        self.tableView.reloadData()
        if direction != .all, let nodeValue = traverseRoot.nodeValue {
            self.dataSource.append(nodeValue)
            if let child = traverseRoot.nodeChild(whichOne: direction) {
                traverseRoot = child
                cityCount = traverseRoot.count + 1
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            var paths = [IndexPath]()
            
            if direction != .all {
                paths.append(IndexPath.init(row: self.dataSource.count-1, section: 0))
            }
            
            traverseRoot.traverseInOrder(process: { (nextCity) in
                DispatchQueue.main.async {
                    let passedFilter = direction != .all ? nextCity.name.startsWith(self.searchController.searchBar.text!) : true
                    
                    if passedFilter {
                        self.dataSource.append(nextCity)
                    }else{
                        cityCount -= 1
                    }
                    
                    if direction == .all && !primerLoaded {
                        let nextIndexPath = IndexPath.init(row: self.dataSource.count-1, section: 0)
                        paths.append(nextIndexPath)

                        if self.dataSource.count == 220 {
                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: paths, with: .fade)
                            self.tableView.endUpdates()
                            primerLoaded = true
                        }
                        
                    }

                    if self.dataSource.count == cityCount {
                        self.tableView.reloadData()
                        self.setupSearchController()
                        print("Loaded \(cityCount) items")
                    }
                    
                }
            })
        }

    }
    
    func setupSearchController() {
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.barTintColor = UIColor.black
        self.navigationItem.searchController = self.searchController
        self.searchController.searchBar.placeholder = "Search Producer"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        if isFiltering() {
            
            isNarrowingSearch = lastSearchTerm.count < searchController.searchBar.text!.count
            processSearchResults(searchTerm: searchController.searchBar.text!)
            lastSearchTerm = searchController.searchBar.text!
            
//            if let branch = self.cityTree?.searchPrefix(searchValue: searchController.searchBar.text!) {
//
//                if searchController.searchBar.text!.count == 1 {
//                    traverseCityTree(atNode: branch)
//                }else{
//                    if let city = branch.nodeValue {
//                        processSearchResults(matchingCity: city)
//                    }
//                }
//            }
        }else{
            self.dataSource = self.masterDataSource
            self.tableView.reloadData()
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    // MARK: - Table View
    
    func cellIdentifier(at indexPath: IndexPath) -> String {
        return "CellID"
    }
    
    func nextCellForTableView(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(at: indexPath))
        
        if (cell == nil) {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: self.cellIdentifier(at: indexPath))
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.nextCellForTableView(tableView, at: indexPath)
        let city = self.dataSource[indexPath.row]

        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.country
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.sizeClass().horizontal == .compact {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//        self.performSegue(withIdentifier: "blockDetailSegue", sender: indexPath)
//    }
    
    // MARK: - Storyboard
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "blockDetailSegue" {
//            if let indexPath = sender as? IndexPath {
//                let block: Block = fetchedResultsController().object(at: indexPath)
//                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                vc.block = block
//                vc.navigationItem.title = block.producer
//                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                vc.navigationItem.leftItemsSupplementBackButton = true
//
//                //this clears the title of the back button to leave only the chevron
//                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//            }
//        }
//    }
    
}
