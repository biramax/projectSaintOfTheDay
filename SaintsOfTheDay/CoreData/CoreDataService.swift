//
//  CoreDataService.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 05.03.2024.
//

import Foundation
import CoreData

final class CoreDataService {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer (name: "CoreDataModel")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                print(error)
            }
        })
        return persistentContainer
    }()
    
    // Сохраняем данные о святых
    func saveSaints(saints: [Saint]) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Saints")
        
        // Удаляем старые данные
        deleteAllSaints()
        
        // Сохраняем новые данные
        for saint in saints {
            
            // Ищем среди сохранённых святых святого с данным id
            fetchRequest.predicate = NSPredicate(format: "id = %@", argumentArray: [saint.id])
            let result = try? persistentContainer.viewContext.fetch(fetchRequest)
            guard result?.first == nil else {
                continue
            }
            
            // Если такого святого нет в CoreData, добавляем
            let saintModel = Saints(context: persistentContainer.viewContext)
            saintModel.id = Int64(saint.id)
            saintModel.name = saint.name
            saintModel.descr = saint.description
            saintModel.iconUrlS = saint.highestPriorityIconUrlS()
            saintModel.iconUrlM = saint.highestPriorityIconUrlM()
            saintModel.iconUrlL = saint.highestPriorityIconUrlL()
        }
        
        save()
        
        // Сохраняем текущую дату
        saveSaintsDate()
    }
    
    // Получаем данные о святых
    func getSaints() -> [Saint] {
        
        let fetchRequest: NSFetchRequest<Saints> = Saints.fetchRequest()

        guard let saints = try? persistentContainer.viewContext.fetch(fetchRequest) else {
            return []
        }

        var allSaints: [Saint] = []

        for saint in saints {
            // Преобразуем CoreData объект иконы в массив икон
            let icons: [Saint.Icon] = [
                Saint.Icon(priority: 0,
                           urlS: saint.iconUrlS ?? "",
                           urlM: saint.iconUrlM ?? "",
                           urlL: saint.iconUrlL ?? "")
            ]

            // Создаем экземпляр Saint с массивом икон
            let saintModel = Saint(
                id: Int(saint.id),
                name: saint.name ?? "",
                description: saint.descr ?? "",
                icons: icons
            )

            allSaints.append(saintModel)
        }

        return allSaints
    }
    
    // Получаем данные о конкретном святом
    func getSaint(_ id: Int) -> Saint? {
        
        let fetchRequest: NSFetchRequest<Saints> = Saints.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        guard let saint = try? persistentContainer.viewContext.fetch(fetchRequest).first else {
            return nil
        }

        let icons: [Saint.Icon] = [
            Saint.Icon(priority: 0,
                       urlS: saint.iconUrlS ?? "",
                       urlM: saint.iconUrlM ?? "",
                       urlL: saint.iconUrlL ?? "")
        ]

        let saintModel = Saint(
            id: Int(saint.id),
            name: saint.name ?? "",
            description: saint.descr ?? "",
            icons: icons
        )

        return saintModel
    }

    
    // Удаляем все данные о святых
    private func deleteAllSaints() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Saints")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting Saints: \(error.localizedDescription)")
        }
    }
}



extension CoreDataService {
        
    func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func delete(object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
        save()
    }
}


// Сохранение и получение даты последнего изменения данных святых
extension CoreDataService {
    
    func saveSaintsDate() {
        let context = persistentContainer.viewContext
        // Удаляем старые данные
        deleteAllSaintsDate()
        let date = SaintsDate(context: context)
        date.date = Date()
        save()
    }
    
    func getSaintsDate() -> Date? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SaintsDate> = SaintsDate.fetchRequest()
        do {
            let dates = try context.fetch(fetchRequest)
            return dates.first?.date
        } catch {
            print("Error fetching SaintsDate: \(error.localizedDescription)")
            return nil
        }
    }

    // Удаление всех дат
    private func deleteAllSaintsDate() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SaintsDate")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting SaintsDate: \(error.localizedDescription)")
        }
    }
}
