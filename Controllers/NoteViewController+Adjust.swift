//
//  NoteViewController+Adjust.swift
//  Notes
//
//  Created by Zachary Oxendine on 2/11/21.
//

import UIKit

extension NoteViewController {
    // MARK: - Fix for Text View Scrolling w/ Keyboard

    // Add observers for the keyboard.
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustInsets),
                                       name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustInsets),
                                       name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // Adjust insets for the keyboard.
    @objc func adjustInsets(notification: Notification) {
        let keyboardFrameEndUserInfoKey = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]

        if let keyboardValue = keyboardFrameEndUserInfoKey as? NSValue {
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            let bottomEdgeInset = keyboardViewEndFrame.height - view.safeAreaInsets.bottom

            if notification.name == UIResponder.keyboardWillHideNotification {
                textView.contentInset = .zero
            } else {
                textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomEdgeInset, right: 0)
            }

            textView.scrollIndicatorInsets = textView.contentInset
            textView.scrollRangeToVisible(textView.selectedRange)
        }
    }
}
