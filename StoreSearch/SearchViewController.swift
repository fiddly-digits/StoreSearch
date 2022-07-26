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
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            hasSearched = true
            searchResults = []
            
            let url = iTunesUrl(searchText: searchBar.text!)
            print("URL: \(url) ")
            if let data = performStoreRequest(with: url) {
                searchResults = parse(data: data)
                searchResults.sort(by: <) //{ $0 > $1 }
            } else {
                showNetworkError()
            }
            tableView.reloadData()
        }
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
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }
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

//MARK: - Helper Methods - Networking

func iTunesUrl(searchText: String) -> URL {
    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
    let url = URL(string: urlString)
    return url!
}

func performStoreRequest(with url: URL) -> Data? {
    do {
        return try Data(contentsOf: url)
    } catch {
        print("Download Error: \(error.localizedDescription)")
        return nil
    }
}

func parse(data: Data) -> [SearchResult] {
    do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ResultArray.self, from: data)
        return result.results
    } catch {
        print("JSON Error: \(error)")
        return []
    }
}


// MARK: - Error Alert Notification

extension SearchViewController {
    func showNetworkError() {
        let alert = UIAlertController(title: "Error", message: "There was an error accessing the iTunes Store" + " Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Code for testing comparations and reduce closure

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedDescending
}
