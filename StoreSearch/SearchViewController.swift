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
    
    var searchResults = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }


}

//MARK: - SearchView Extension
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = []
        for i in 0...2 {
            searchResults.append(String(format: "Fake result %d for '%@'", i, searchBar.text!))
        }
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

//MARK: - TableView Dataview & Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cellIdentifier = "SearchResultCell"
      var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
      if cell == nil {
        cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
      }
        cell?.textLabel!.text = searchResults[indexPath.row]
        return cell!
    }
}
