//
//  MenuViewController.swift
//  StoreSearch
//
//  Created by Roberto Cruz on 08/08/22.
//

import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewControllerSendEmail(_ controller: MenuViewController)
}


class MenuViewController: UITableViewController {
    
    weak var delegate: MenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Use this observer to fix table to content size in the popover, along with observe value.
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.preferredContentSize = tableView.contentSize
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
}

// MARK: - TableView Delegates

extension MenuViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.menuViewControllerSendEmail(self)
        }
    }
}
