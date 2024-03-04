//
//  NetworkService.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 28.02.2024.
//

import Foundation

final class NetworkService {
    
    // Стандартная сессия
    private let session = URLSession.shared
    
    // Получаем токен
    func getToken() {
        
        // URL запроса
        guard let url = URL(string: "https://azbyka.ru/days/api/login") else {
            return
        }
        
        let email = "bm@yandex.ru"
        let password = "$0fBr7eM,mpKf"
        let parameters = ["email": email, "password": password]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        session.dataTask(with: request) { (data, response, error) in
            
            // Проверяем на получение ошибки
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Проверяем, пришли ли к нам данные
            guard let data else {
                return
            }

            do {
                // Преобразуем полученный json
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let token = jsonResponse["token"] as? String {
                        
                        //print("Token: \(token)")
                        
                        // Сохраняем токен в UserDefaults
                        UserDefaultsService.saveToken(token: token)
                        
                    } else {
                        print("Token not found in response")
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }.resume()
    }
    
    
    
    // Получаем массив id святых сегодняшнего дня
    func getSaintsIds(date: String, completion: @escaping ([Int]?) -> Void) {
        
        // URL запроса
        guard let url = URL(string: "https://azbyka.ru/days/api/cache_dates?date[exact]=\(date)") else {
            return
        }
        
        let token = UserDefaultsService.getToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { (data, response, error) in
            
            // Проверяем на получение ошибки
            if let error = error {
                print("Error: \(error)")
                completion(nil)
            }
            
            // Проверяем, пришли ли к нам данные
            guard let data else {
                return
            }

            do {
//             Пример получаемых данных
//                [
//                  {
//                    "abstractDate": {
//                      "texts": [],
//                      "holidays": [],
//                      "tropariaOrKontakia": [],
//                      "canonsOrAkathists": [],
//                      "saintsGroupAbstractDate": [
//                        {
//                          "saintsGroup": {
//                            "id": 156,
//                            "cacheTitle": "Священномученики Михаи́л Пятаев и Иоа́нн Куминов",
//                            "uri": "mihail-pjataev-ioann-kuminov"
//                          }
//                        }
//                      ],
//                      "saintAbstractDates": [
//                        {
//                          "saint": {
//                            "id": 1322,
//                            "title": "Пафну́тий Александрийский",
//                            "uri": "pafnutij-aleksandrijskij"
//                          }
//                        },
//                        {
//                          "saint": {
//                            "id": 1744,
//                            "title": "Па́вел (Козлов)",
//                            "uri": "pavel-kozlov"
//                          }
//                        },
//                        {
//                          "saint": {
//                            "id": 2738,
//                            "title": "Михаи́л Пятаев",
//                            "uri": "mihail-pjataev"
//                          }
//                        },
//                        {
//                          "saint": {
//                            "id": 5540,
//                            "title": "Иоа́нн Куминов",
//                            "uri": "ioann-kuminov"
//                          }
//                        }
//                      ],
//                      "iconsOfOurLadyAbstractDates": [
//                        {
//                          "iconsOfOurLady": {
//                            "id": 152,
//                            "title": "Виленская",
//                            "uri": "vilenskaja"
//                          }
//                        }
//                      ]
//                    }
//                  },
//                  {
//                    "abstractDate": {
//                      "texts": [],
//                      "holidays": [],
//                      "tropariaOrKontakia": [],
//                      "canonsOrAkathists": [],
//                      "saintsGroupAbstractDate": [],
//                      "saintAbstractDates": [],
//                      "iconsOfOurLadyAbstractDates": []
//                    }
//                  },
//                  
//                  ...
//                  
//                  {
//                    "abstractDate": {
//                      "texts": [],
//                      "holidays": [],
//                      "tropariaOrKontakia": [],
//                      "canonsOrAkathists": [],
//                      "saintsGroupAbstractDate": [],
//                      "saintAbstractDates": [],
//                      "iconsOfOurLadyAbstractDates": []
//                    }
//                  }
//                ]
                
                // Преобразуем полученный json
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Собираем id всех святых.
                
                if let jsonArray = jsonResponse as? [[String: Any]] {
                    
                    // flatMap используется для итерации по каждому элементу массива и извлечения значений из abstractDate -> saintAbstractDates.
                    // nil фильтруются, чтобы избежать возможных nil в результирующем массиве.
                    let allSaintIds = jsonArray.flatMap { item -> [Int] in
                        guard let abstractDate = item["abstractDate"] as? [String: Any],
                              let saintAbstractDates = abstractDate["saintAbstractDates"] as? [[String: Any]] else {
                            return []
                        }
                        
                        // compactMap используется для извлечения идентификаторов из saint для каждого элемента saintAbstractDates.
                        return saintAbstractDates.compactMap { saintAbstractDate in
                            guard let saint = saintAbstractDate["saint"] as? [String: Any],
                                  let saintId = saint["id"] as? Int else {
                                return nil
                            }
                            return saintId
                        }
                    }
                    completion(allSaintIds)
                } else {
                    print("Invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                completion(nil)
            }
        }.resume()
        
    }
    
    // По ID святых запрашиваем данные - имя и икону святого
    func getSaintsByIds(saintsIds: [Int], completion: @escaping([Saint]?) -> Void) {
        
        // Массив для хранения всех святых
        var allSaints: [Saint] = []
        
        // Используем для отслеживания завершения всех запросов
        let dispatchGroup = DispatchGroup()
        
        for saintId in saintsIds {
            
            // Вход в группу перед запросом
            dispatchGroup.enter()

            getSaintById(saintId: saintId) { saint in
                
                // Добавляем святого в массив
                if let saint = saint {
                    allSaints.append(saint)
                }
                
                // Выход из группы после завершения запроса
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allSaints)
        }
    }
    
    // Получаем данные о конкретном святом по его ID
    func getSaintById(saintId: Int, completion: @escaping (Saint?) -> Void) {
        
        let token = UserDefaultsService.getToken()

        // URL запроса
        guard let url = URL(string: "https://azbyka.ru/days/api/saints/\(saintId)") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { (data, response, error) in
            
            // Проверяем на получение ошибки
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            // Проверяем, пришли ли к нам данные
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let saint = try JSONDecoder().decode(Saint.self, from: data)
                completion(saint)
                
            } catch {
                print("Error deserializing JSON: \(error)")
                completion(nil)
            }

        }.resume()
    }
}
