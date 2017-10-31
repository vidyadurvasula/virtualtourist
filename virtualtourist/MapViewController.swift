//
//  ViewController.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/24/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate {
    var pins = [Pin]()
    var tappedPin: Pin? = nil
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var deletelabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            fetchedResultsController?.delegate = self
        }
    }
    
    // Initializers
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deletelabel.isHidden = true
        // Set bar button item title
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Set delegate
        map.delegate = self
        
        // Add gesture recognizer
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addNewAnnotation(_:)))
        longTouch.minimumPressDuration = 1.0
        map.addGestureRecognizer(longTouch)
        
        // Map all persistant data
        mapSavedAnnotations()
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: false)
        if editing {
            // Show delete message view when editing button is tapped
            UIView.animate(withDuration: 0.1, animations: {
                self.deletelabel.isHidden = false
            })} else {
            self.deletelabel.isHidden = true
        }
        
    }
    // MARK: Helper Functions
    
    // Create fetch request
    func pinFetchRequest() -> [Pin] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true), NSSortDescriptor(key: "long", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Get the saved pins
        do {
            return try context.fetch(fetchRequest) as! [Pin]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Pin]()
        }
    }
    
    // Map persistent data
    func mapSavedAnnotations() {
        
        pins = pinFetchRequest()
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            map.addAnnotation(annotation)
        }
    }
    
    // Add new drop pin
    @objc func addNewAnnotation(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            let tapPoint = sender.location(in: self.map)
            let mapCoordinate = map.convert(tapPoint, toCoordinateFrom: map)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapCoordinate
            
            // add annotation to core data and store Lat / Long in core data
            if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
                let newPin = Pin(entity: entity, insertInto: context)
                newPin.lat = annotation.coordinate.latitude
                newPin.long = annotation.coordinate.longitude
                pins.append(newPin)
                
                // Add photos to new pin
                FlickrNetworkManager.sharedNetworkManager.addnewphoto(newPin, completionhandler:  { _ in do {
                    try delegate.stack.saveContext()}
                catch {
                    print("Error downloading initial photos.")
                    }
                })
            }
            
            // Save data
            do {
                try delegate.stack.saveContext()
            } catch {
                print("Error saving pin data")
            }
            
            // set map point
            map.addAnnotation(annotation)
            
        }
    }
    
    // Function changes view controller state
    
    
    func viewPin(_ tappedPin: Pin) {
        
        let photoVC = storyboard!.instantiateViewController(withIdentifier: "kPhotoCollectionController") as! PhotoCollectionViewController
        
        photoVC.pin = tappedPin
        navigationController!.pushViewController(photoVC, animated: true)
    }
    
    // Delete pins from core data
    func deletePins(_ tappedPin: MKAnnotation) {
        
        print("Deleting pin...")
        
        print(tappedPin.coordinate.latitude, tappedPin.coordinate.longitude)
        
        map.removeAnnotation(tappedPin)
        
        // Set context
        let managedObjContext = fetchedResultsController?.managedObjectContext
        
        // Set entity to reference
        let fetchPinsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        // Set rules for predicate (based on Latitude and longitude
        let fetchPredicate = NSPredicate(format: "lat contains %@ AND long contains %@", "\(tappedPin.coordinate.latitude)", "\(tappedPin.coordinate.longitude)")
        fetchPinsRequest.predicate = fetchPredicate
        fetchPinsRequest.returnsObjectsAsFaults = false
        
        let fetchedPins = try! managedObjContext?.fetch(fetchPinsRequest) as? [Pin]
        
        // Remove pin from model
        for pinToDelete in fetchedPins! {
            managedObjContext?.delete(pinToDelete)
        }
        
        do {
            try delegate.stack.saveContext()
        } catch {print("Failed to save after pin deletion.")}
    }
    
    // Delegate method for selection of existing annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = view.annotation
        tappedPin = nil
        
        for pin in pins {
            if annotation!.coordinate.latitude == pin.coordinate.latitude && annotation!.coordinate.longitude == pin.coordinate.longitude {
                tappedPin = pin
                
                // Deselect the pin that was tapped most recently
                mapView.deselectAnnotation(annotation, animated: true)
                
                // Check if the map view controller is in edit mode
                isEditing ? deletePins(annotation!) : viewPin(tappedPin!)
            }
        }
    }
}

