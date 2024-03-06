//
//  StringHelper.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 02.03.2024.
//

import Foundation

extension String {
    
    // Удаление HTML тегов из текста
    func removeHTMLTags() -> String {
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: [])
            let range = NSRange(location: 0, length: self.utf16.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        } catch {
            print("Error removing HTML tags: \(error.localizedDescription)")
            return self
        }
    }
}
