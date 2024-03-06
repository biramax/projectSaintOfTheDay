//
//  Saints+CoreDataProperties.swift
//  SaintsOfTheDay
//
//  Created by Максим Бобков on 05.03.2024.
//
//

import Foundation
import CoreData


extension Saints {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Saints> {
        return NSFetchRequest<Saints>(entityName: "Saints")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var descr: String?
    @NSManaged public var iconUrlS: String?
    @NSManaged public var iconUrlM: String?
    @NSManaged public var iconUrlL: String?

}

extension Saints : Identifiable {

}
