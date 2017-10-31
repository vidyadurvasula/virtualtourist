//
//  Photo+CoreDataClass.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/25/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {


    convenience init(id: String, url: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            
            self.id = id
            self.url = url
        } else {
            fatalError("Unable to find Entity name!")
        }
}
}


