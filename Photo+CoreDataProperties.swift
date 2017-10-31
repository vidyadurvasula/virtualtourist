//
//  Photo+CoreDataProperties.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/25/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: String?
    @NSManaged public var url: String?
    @NSManaged public var imagedata: NSData?
    @NSManaged public var pin: Pin?

}
