//
//  SearchViewController.swift
//  CityLab
//
//  Created by aarthur on 11/9/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pinwheel: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [City]()
    var masterDataSource = [City]()
    var lastSearchTerm = ""
    var isNarrowingSearch = false
    let searchController = UISearchController(searchResultsController: nil)

    func registerTableAssets() {
        var nib: UINib!
        
        nib = UINib.init(nibName: "CityTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: CityTableCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableAssets()
        
        //this will prevent bogus separator lines from displaying in an empty table
        self.tableView.tableFooterView = UIView()
        
        //enable auto cell height that uses constraints
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 45
        
        pinwheel.isHidden = false
        pinwheel.startAnimating()
        
        //allows the pinwheel to spin
        DispatchQueue.global(qos: .background).async {
            self.prepareData()
        }
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
            
            DispatchQueue.main.async {
                self.pinwheel.stopAnimating()
                self.pinwheel.isHidden = true
                self.tableView.isHidden = false
                self.dataSource = cities.sorted()
                self.masterDataSource = self.dataSource
                self.tableView.reloadData()
                self.setupSearchController()
            }

        }
    }
    
    /*
        This does the heavy lifting of the search, invoked on each keystroke
        the datasource will shrink with each keystroke
    */
    func processSearchResults(searchTerm: String) {
        
        func findTerminatingIndex(inArray: Array<City>, startingAt: Int) -> Int {
            if startingAt == 0 {return startingAt}
            
            var floatingIndex = startingAt
            var stop = false
            
            while !stop {
                stop = !inArray[floatingIndex-1].name.startsWith(searchTerm)
                if !stop {
                    floatingIndex -= 1
                    stop = floatingIndex == 0
                }
            }

            return floatingIndex
        }
        
        if !isNarrowingSearch {
            //user just deleted a character from the search bar so we must search the full city array
            self.dataSource = self.masterDataSource
        }
        
        let matchingIndex = self.dataSource.binaryPrefixSearch(searchTerm: searchTerm)
        if let safeIndex = matchingIndex {
            var leadFloatingIndex = safeIndex
            
            //binaryPrefixSearch may have landed us in the middle of our result set
            //step backwards until we find the first match in the result set
            leadFloatingIndex = findTerminatingIndex(inArray: self.dataSource, startingAt: safeIndex)

            //now we need to find the end of the matching results
            let slice = self.dataSource[leadFloatingIndex...self.dataSource.count-1]
            var subarray = Array(slice)

            let trailFloatingIndex = subarray.binaryPrefixSearchOutOfRange(searchTerm: searchTerm)
            subarray = Array(subarray[0...trailFloatingIndex])
            self.dataSource = subarray.filter({ (nextCity) -> Bool in
                return nextCity.name.startsWith(searchTerm)
            })
            
        }
        else{
            //nothing matched
            self.dataSource.removeAll()
        }
    }
    
    func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.barTintColor = UIColor.black
        self.navigationItem.searchController = self.searchController
        self.searchController.searchBar.placeholder = "Search City"
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }

    // MARK: - Size Class

    class func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let window: UIWindow = appDelegate.window!
        let vSizeClass: UIUserInterfaceSizeClass!
        let hSizeClass: UIUserInterfaceSizeClass!
        
        hSizeClass = window.traitCollection.horizontalSizeClass
        vSizeClass = window.traitCollection.verticalSizeClass
        
        return (vertical: vSizeClass, horizontal: hSizeClass)
    }

    func sizeClass() -> (vertical: UIUserInterfaceSizeClass, horizontal: UIUserInterfaceSizeClass) {
        return SearchViewController.sizeClass()
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        if isFiltering() {
            isNarrowingSearch = lastSearchTerm.count < searchController.searchBar.text!.count
            
            //for some bogus reason re-loading the table view will occassionally trigger
            //scrollview delegate method scrollViewDidScroll which de-activates the search
            //and dismisses the keyboard
            //this hack gets around that
            self.tableView.delegate = nil
            processSearchResults(searchTerm: searchController.searchBar.text!)
            self.tableView.reloadData()
            self.tableView.delegate = self
            lastSearchTerm = searchController.searchBar.text!
        }else if searchBarIsEmpty()
        {
            self.dataSource = self.masterDataSource
            self.tableView.reloadData()
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /*
        True when the search is active and the search bar is NOT empty
    */
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }

    // MARK: - Table View

    func cellIdentifier(at indexPath: IndexPath) -> String {
        return CityTableCell.cell_id
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
        let cell: CityTableCell = self.nextCellForTableView(tableView, at: indexPath) as! CityTableCell
        let city = self.dataSource[indexPath.row]

        if self.isFiltering() {
            let highlightedSearchTerm = NSMutableAttributedString(string: city.name)
            let range = city.name.range(of: searchController.searchBar.text!, options: .caseInsensitive)
            
            //highlight the city name characters matching search bar
            highlightedSearchTerm.addAttribute(.backgroundColor,
                                               value: UIColor.yellow,
                                               range: NSRange.init(location: (range?.lowerBound.encodedOffset)!,
                                                                   length: (range?.upperBound.encodedOffset)! - (range?.lowerBound.encodedOffset)!))
            cell.cityLabel?.attributedText = highlightedSearchTerm
        }
        else{
            cell.cityLabel?.text = city.name
        }
        cell.countryLabel?.text = city.country
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.sizeClass().horizontal == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        self.performSegue(withIdentifier: "cityDetailSegue", sender: indexPath)
    }
    
    // MARK: - Storyboard

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "cityDetailSegue" {
            if let indexPath = sender as? IndexPath {
                let city = self.dataSource[indexPath.row]
                let vc = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                vc.city = city
                vc.navigationItem.title = city.cityDisplayTitle()
                vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                vc.navigationItem.leftItemsSupplementBackButton = true

                //this clears the title of the back button to leave only the chevron
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }
    
}
