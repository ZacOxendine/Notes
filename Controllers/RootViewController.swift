//
//  RootViewController.swift
//  Notes
//
//  Created by Zachary Oxendine on 2/11/21.
//

import UIKit

class RootViewController: UITableViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    let notesKey = "Notes Key"
    var notes: [Note] = []
    var filteredNotes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotes()
        setupNavigationBar()
        setupToolbar()
    }

    // MARK: - Setup

    func setupNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
    }

    func setupToolbar() {
        navigationController?.isToolbarHidden = false
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
        ]
    }

    // MARK: - Actions for Button Items

    @objc func composeTapped() {
        let alertController = UIAlertController(title: "Compose Note Title:", message: nil, preferredStyle: .alert)
        alertController.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alertController] _ in
            if let title = alertController?.textFields?[0].text {
                self?.submitNote(title)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }

    // MARK: - Submitting & Deleting Notes

    func submitNote(_ title: String) {
        let note = Note(uuidString: UUID().uuidString, title: title, text: "")
        let indexPath = IndexPath(row: notes.count, section: 0)

        notes.append(note)
        tableView.insertRows(at: [indexPath], with: .automatic)
        saveNotes()
    }

    func deleteNote(at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete Note",
                                                message: "This will permanently delete your note.",
                                                preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] _ in
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveNotes()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }

    // MARK: - Saving & Loading Notes

    func saveNotes() {
        let jsonEncoder = JSONEncoder()

        if let savedNotes = try? jsonEncoder.encode(notes) {
            UserDefaults.standard.set(savedNotes, forKey: notesKey)
        }
    }

    func loadNotes() {
        if let savedNotes = UserDefaults.standard.object(forKey: notesKey) as? Data {
            let jsonDecoder = JSONDecoder()

            if let loadedNotes = try? jsonDecoder.decode([Note].self, from: savedNotes) {
                notes = loadedNotes
            }
        }
    }

    // MARK: - Table View Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNotes.count
        } else {
            return notes.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "Note Cell", for: indexPath)
        let note: Note

        if isFiltering {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }

        noteCell.textLabel?.text = note.title
        noteCell.accessoryType = .disclosureIndicator

        return noteCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "Note View") as? NoteViewController {
            let note: Note

            if isFiltering {
                note = filteredNotes[indexPath.row]
            } else {
                note = notes[indexPath.row]
            }

            viewController.note = note
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // Logic for deleting table view rows while editing is enabled or swiping right-to-left on a row.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(at: indexPath)
        }
    }

    // Logic for moving table view rows while editing is enabled.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let noteSource = notes[sourceIndexPath.row]
        notes.remove(at: sourceIndexPath.row)
        notes.insert(noteSource, at: destinationIndexPath.row)
        saveNotes()
    }
}
