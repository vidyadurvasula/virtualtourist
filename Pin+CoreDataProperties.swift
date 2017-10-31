//
//  Pin+CoreDataProperties.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/25/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var photo: NSSet?

}

// MARK: Generated accessors for photo
extension Pin {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}
