//
//  RootViewController+Filter.swift
//  Notes
//
//  Created by Zachary Oxendine on 2/11/21.
//

import UIKit

extension RootViewController {
    // MARK: - Filter/Search Methods

    // Is the search bar empty?
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    // Is the search controller active? Is the search bar **not** empty?
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    // Update the filtered notes for the search results.
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            filteredNotes = notes.filter { (note: Note) -> Bool in
                return note.title.lowercased().contains(text.lowercased())
            }

            tableView.reloadData()
        }
    }
}
