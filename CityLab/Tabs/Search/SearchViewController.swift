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
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()

        initializeCityTree()
        traverseCityTree(atNode: self.cityTree!)
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
    
    func traverseCityTree(atNode: BinaryTree<City>, load: Bool = true) {
        let cityCount = atNode.count
        var primerLoaded = false

        self.dataSource.removeAll()
        self.tableView.reloadData()
        DispatchQueue.global(qos: .background).async {
            var paths = [IndexPath]()
            
            atNode.traverseInOrder(process: { (nextCity) in
                DispatchQueue.main.async {
                    self.dataSource.append(nextCity)
                    
                    if !primerLoaded {
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
            if let branch = self.cityTree?.searchPrefix(searchValue: searchController.searchBar.text!) {
                traverseCityTree(atNode: branch)
            }
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
            cell = UITableViewCell.init(style: .default, reuseIdentifier: self.cellIdentifier(at: indexPath))
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
