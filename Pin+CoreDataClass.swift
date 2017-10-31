//
//  Pin+CoreDataClass.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/25/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject, MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        set {
            lat = newValue.latitude
            long = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }
    
    convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.long = long
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
