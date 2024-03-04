//
//  DateHelper.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 28.02.2024.
//

import Foundation

final class DateHelper {
    
    // Получаем текущую дату в формате ГГГГ-ММ-ДД
    static func getCurrentDate() -> String {
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: currentDate)
    }
    
    // Получаем дату в формате ДД.ММ.ГГГГ ЧЧ:ММ из метки времени
    static func getDate(date: Date?) -> String {
        
        guard let date else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY hh:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter.string(from: date)
    }
}
