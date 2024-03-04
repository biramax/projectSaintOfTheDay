//
//  UserDefaults.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 28.02.2024.
//

import Foundation

final class UserDefaultsService {
    
    // Создаём хранилище UserDefaults
    static var userDefaults = UserDefaults.standard
    
    // Сохраняем токен
    static func saveToken(token: String) {
        userDefaults.set(token, forKey: "token")
    }
    
    // Получаем токен
    static func getToken() -> String? {
        
        if let token = userDefaults.string(forKey: "token") {
            return token
        } else {
            print("Token not found in UserDefaults")
            return nil
        }
    }
}
