//
//  SaintShortModel.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 29.02.2024.
//


//{
//  "id": 545,
//  "title": "Иса́ия Египтянин, Кесарийский (Палестинский)",
//  "titleClean": "Исаия Египтянин Кесарийский Палестинский",
//  "name": "Исаия",
//  "sex": "man",
//  "newmartyr": false,
//  "isMenologyRpc": true,
//  "description": "<h3 style=\"text-align: center;\">Жития священномучеников Памфила, пресвитера, Валента, диакона, мучеников Павла, Порфирия, Селевкия, Феодула, Иулиана, Самуила, Илии, Даниила, Иеремии и Исаии</h3>\r\n\r\n<p>Святые 12 мучеников &ndash; Памфил пресвитер, Валент (Уалент) диакон, Павел, Порфирий, Селевкий, Феодул, Иулиан, Самуил, Илия, Даниил, Иеремия, Исаия пострадали во время гонения на христиан, воздвигнутого императором Диоклитианом в 308&ndash;309 годах в Кесарии Палестинской...</p>",
//  "temples": "",
//  "uri": "isaija-egiptjanin-kesarijskij-palestinskij",
//  "titleGenitive": "Иса́ии",
//  "isCathedral": false,
//  "typeOfSanctity": {
//    "id": 14,
//    "title": "мч.",
//    "titlePlural": "мчч.",
//    "completeTitle": "мученик",
//    "completeTitlePlural": "мученики",
//    "completeTitleFemale": "мученица",
//    "completeTitlePluralFemale": "мученицы"
//  },
//  "canonsOrAkathists": [],
//  "tropariaOrKontakia": [],
//  "icons": [
//    {
//      "id": 14418,
//      "filename": "p1e93jspib3qd6l4dbs1j6g1bd33.jpg",
//      "priority": 91,
//      "description": "",
//      "saint_id": 545,
//      "preview": "preview_100_100__p1e93jspib3qd6l4dbs1j6g1bd33.jpg",
//      "image": "p1e93jspib3qd6l4dbs1j6g1bd33.jpg",
//      "original_absolute_url": "https://azbyka.ru/days/storage/images/icons-of-saints/3494/p1e93jspib3qd6l4dbs1j6g1bd33.jpg",
//      "preview_absolute_url": "https://azbyka.ru/days/cache/200x160/storage/images/icons-of-saints/3494/p1e93jspib3qd6l4dbs1j6g1bd33.jpg",
//      "preview_absolute_url_2x": "https://azbyka.ru/days/cache/400x320/storage/images/icons-of-saints/3494/p1e93jspib3qd6l4dbs1j6g1bd33.jpg"
//    },
//    {
//      "id": 14419,
//      "filename": "p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg",
//      "priority": 92,
//      "description": "",
//      "saint_id": 545,
//      "preview": "preview_100_100__p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg",
//      "image": "p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg",
//      "original_absolute_url": "https://azbyka.ru/days/storage/images/icons-of-saints/3494/p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg",
//      "preview_absolute_url": "https://azbyka.ru/days/cache/200x160/storage/images/icons-of-saints/3494/p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg",
//      "preview_absolute_url_2x": "https://azbyka.ru/days/cache/400x320/storage/images/icons-of-saints/3494/p1e93jspid1a5e1v5m1f3n16bk16eh4.jpg"
//    }
//  ]
//}

struct Saint: Decodable {
    let id: Int
    let name: String
    let description: String
    let icons: [Icon] // Массив икон
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case description
        case icons
    }
    
    // Вложенная структура для икон
    struct Icon: Decodable {
        let priority: Int
        let urlS: String
        let urlM: String
        let urlL: String
        
        enum CodingKeys: String, CodingKey {
            case priority
            case urlS = "preview_absolute_url"
            case urlM = "preview_absolute_url_2x"
            case urlL = "original_absolute_url"
        }
    }
    
    func highestPriorityIconUrlS() -> String? {
        let highestPriorityIcon = icons.max(by: { $0.priority < $1.priority })
        return highestPriorityIcon?.urlS
    }
    
    func highestPriorityIconUrlM() -> String? {
        let highestPriorityIcon = icons.max(by: { $0.priority < $1.priority })
        return highestPriorityIcon?.urlM
    }
    
    func highestPriorityIconUrlL() -> String? {
        let highestPriorityIcon = icons.max(by: { $0.priority < $1.priority })
        return highestPriorityIcon?.urlL
    }
}
