//
//  NoteViewController.swift
//  Notes
//
//  Created by Zachary Oxendine on 2/11/21.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    let toolbarForKeyboard = UIToolbar()
    let undoButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undoTapped))
    let redoButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redoTapped))
    @IBOutlet weak var textView: UITextView!
    weak var delegate: RootViewController!
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTextView()
        setupToolbars()
        updateUndoButtonItem()
        updateRedoButtonItem()
        addObservers()
    }

    // When the text view changes, save the notes and update the undo/redo button items.
    func textViewDidChange(_ textView: UITextView) {
        note?.text = textView.text
        delegate.saveNotes()
        updateUndoButtonItem()
        updateRedoButtonItem()
    }

    // MARK: - Setup

    func setupNavigationBar() {
        navigationItem.title = note?.title
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        ]
    }

    func setupTextView() {
        textView.delegate = self;
        textView.text = note?.text
        textView.inputAccessoryView = toolbarForKeyboard
    }

    func setupToolbars() {
        toolbarForKeyboard.sizeToFit()
        toolbarForKeyboard.items = [
            undoButtonItem, redoButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        ]

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionTapped))
        ]
    }

    // MARK: - Update Undo/Redo Button Items

    // If the text view can be undone, enable the undo button item.
    func updateUndoButtonItem() {
        if textView.undoManager?.canUndo == true {
            undoButtonItem.isEnabled = true
            undoButtonItem.tintColor = UIColor.systemBlue
        } else {
            undoButtonItem.isEnabled = false
            undoButtonItem.tintColor = UIColor.systemGray
        }
    }

    // If the text view can be redone, enable the redo button item.
    func updateRedoButtonItem() {
        if textView.undoManager?.canRedo == true {
            redoButtonItem.isEnabled = true
            redoButtonItem.tintColor = UIColor.systemBlue
        } else {
            redoButtonItem.isEnabled = false
            redoButtonItem.tintColor = UIColor.systemGray
        }
    }

    // MARK: - Actions for Button Items

    @objc func editTapped() {
        let alertController = UIAlertController(title: "Edit Note Title:", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?[0].text = note?.title

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self, weak alertController] _ in
            if let title = alertController?.textFields?[0].text {
                self?.note?.title = title
                self?.navigationItem.title = self?.note?.title
                self?.delegate.saveNotes()
                self?.delegate.tableView.reloadData()
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }

    // Undo the note text.
    @objc func undoTapped() {
        textView.undoManager?.undo()
        updateUndoButtonItem()
    }

    // Redo the undone note text.
    @objc func redoTapped() {
        textView.undoManager?.redo()
        updateRedoButtonItem()
    }

    // Close the keyboard.
    @objc func doneTapped() {
        self.view.endEditing(true)
    }

    // Copy, share, etc. the note text.
    @objc func actionTapped() {
        if let noteText = textView.text {
            let activityViewController = UIActivityViewController(activityItems: [noteText], applicationActivities: [])
            activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(activityViewController, animated: true)
        }
    }
}
