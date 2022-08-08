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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let search = Search()
    var landscapeVC: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
        
        
        listenForFontChanges()
        title = NSLocalizedString("Search", comment: "split view primary button")
        
        //MARK: - Nib/Xib Registration
        var cellNib = UINib(nibName: Constants.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.CellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: Constants.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.CellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: Constants.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.CellIdentifiers.loadingCell)
    }
    
    // MARK: - Transition to child view controller
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }
    
    
}

//MARK: - SearchView Extension
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex){
            search.performSearch(for: searchBar.text!, category: category) { success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeVC?.searchResultsRecived()
            }
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: Segmented Control

extension SearchViewController {
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment Changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
}

//MARK: - TableView Dataview & Delegate Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            // Should never get here
            fatalError("\(Error.self)")
            
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    //fix tapping on a row and become selected and stay selected didSelectRowAt, deselects row and willSelectRowAt make sure we can only select row when we have actual search results
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController?.displayMode != .oneBesideSecondary {
                hidePrimaryPane()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}

// MARK: - Error Alert Notification

extension SearchViewController {
    func showNetworkError() {
        let alert = UIAlertController(title: "Error", message: NSLocalizedString("There was an error accessing the iTunes Store. Please try again", comment: "Error alert: message"), preferredStyle: .alert)
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

// MARK: - Navigation

extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }
        }
    }
}

// MARK: - Listen for font change
extension SearchViewController {
    func listenForFontChanges() {
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.tableView.reloadData()
//            print("Observer executed")
        }
    }
}

// MARK: - Child View Controller
extension SearchViewController {
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard?.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
            } completion: { _ in
                controller.didMove(toParent: self)
                if self.presentedViewController != nil {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            }

        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            
            coordinator.animate { _ in
                controller.view.alpha = 0
                self.searchBar.becomeFirstResponder()
                //deallocates view when rotate back to portrait
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            } completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            }
        }
    }
}

// MARK: - iPAD
extension SearchViewController {
    private func hidePrimaryPane() {
        UIView.animate(withDuration: 0.25) {
            self.splitViewController?.preferredDisplayMode = .secondaryOnly
        } completion: { _ in
            self.splitViewController?.preferredDisplayMode = .automatic
        }

    }
}

