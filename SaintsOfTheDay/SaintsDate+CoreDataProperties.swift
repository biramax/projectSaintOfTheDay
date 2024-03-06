//
//  SaintsDate+CoreDataProperties.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 05.03.2024.
//
//

import Foundation
import CoreData


extension SaintsDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SaintsDate> {
        return NSFetchRequest<SaintsDate>(entityName: "SaintsDate")
    }

    @NSManaged public var date: Date?

}

extension SaintsDate : Identifiable {

}
