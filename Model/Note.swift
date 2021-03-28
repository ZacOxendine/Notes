//
//  Note.swift
//  Notes
//
//  Created by Zachary Oxendine on 2/11/21.
//

import Foundation

class Note: Codable {
    var uuidString: String
    var title: String
    var text: String

    init(uuidString: String, title: String, text: String) {
        self.uuidString = uuidString
        self.title = title
        self.text = text
    }
}
