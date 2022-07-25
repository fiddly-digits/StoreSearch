//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Roberto Cruz on 21/07/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.becomeFirstResponder()
        //MARK: - Nib/Xib Registration
        var cellNib = UINib(nibName: Constants.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: Constants.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.CellIdentifiers.nothingFoundCell)
    }


}

//MARK: - SearchView Extension
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []
        if searchBar.text! != "The police" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        hasSearched = true
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

//MARK: - TableView Dataview & Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            return cell
        }
    }
    
    //fix tapping on a row and become selected and stay selected didSelectRowAt, deselects row and willSelectRowAt make sure we can only select row when we have actual search results
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else  {
            return indexPath
        }
    }
}
