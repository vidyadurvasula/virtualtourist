//
//  NetworkingManager.swift
//  virtualtourist
//
//  Created by Vidya Durvasula on 10/25/17.
//  Copyright © 2017 Vidya Durvasula. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrNetworkManager: NSObject{
    

    
    // Create singleton instance
    static let sharedNetworkManager = FlickrNetworkManager()
    var randomPage: Int {
        return Int(arc4random_uniform(50) + 1)
    }
    
func bboxString(_ lat: Double, long: Double) -> String {
    
    // ensure bbox is bounded by minimum and maximums
    let BOUNDING_BOX_HALF_WIDTH = 1.0, BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0, LAT_MAX = 90.0
    let LON_MIN = -180.0, LON_MAX = 180.0
    
    // Set mins and maxs
    let bottom_left_lon = max(long - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
    let bottom_left_lat = max(lat - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
    let top_right_lon = min(long + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
    let top_right_lat = min(lat + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
    
    return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
}

 // MARK: ADD INFO TO COREDATA METHODS
    
    func addnewphoto(_ pinn:Pin,completionhandler:@escaping( _ error : String?)->Void){
        
        getPhotosUsingCoordinates(pinn.coordinate.latitude, long: pinn.coordinate.longitude) { (photos,error) -> Void in
             DispatchQueue.main.async {
                if (error != nil) {
                    print(error!)
                    completionhandler(error)
                }
                var photoitems : Photo?
                print("Getting new photos for dropped pin...")
                 // Add web URLs and Pin(s) only at this point...
                if photoitems == nil {
                    for photo in photos! {
                        if let entity = NSEntityDescription.entity(forEntityName: "Photo",in: context){
                            photoitems = Photo(entity: entity, insertInto: context)
                            photoitems?.url = photo["url_m"] as? String
                            photoitems?.pin = pinn
                        }
                    }
                    
                }
                return completionhandler(nil)
            }
            
    }
      
    }
    
    // MARK: LOAD PHOTOS THAT ARE NOT SAVED IN COREDATA
    
    // Load photos from URLs
    
    func loadphotos (_ indexpath:IndexPath,photoarray:[Photo],completionhandler:@escaping(_ image: UIImage?, _ data: Data?, _ error: String)->Void) {
    
        if  photoarray.count > 0 {
            if photoarray[indexpath.item].url != nil {
               
                let task =  URLSession.shared.dataTask(with: URLRequest(url: URL(string: photoarray[indexpath.item].url!)!)) { (data, response, error) in
                    DispatchQueue.main.async {
                        guard (error == nil) else {
                            print("Photo not loaded")
                            return completionhandler(nil, nil, "Photo not loaded")
                        
                    }
                        guard (data == data),let image = UIImage(data:data!) else {
                            return completionhandler(nil, nil, "Photo not loaded")
                            
                        }
                        completionhandler(image,data,"")
                    }
                }
              
            task.resume()
            }
            
            
    
    }
    }
    
    
private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Flickr.APIScheme
    components.host = Constants.Flickr.APIHost
    components.path = Constants.Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
    }
    
    return components.url!
}
    // Get photo data from touch coordinates
    func getPhotosUsingCoordinates(_ lat: Double, long: Double, page: Int = 1, handler: @escaping (_ photos: [[String : AnyObject]]?, _ error: String?) -> Void) {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(lat, long: long),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            guard let photodictionary = parsedResult["photos"] as? [String : AnyObject] else {
                print("No photos were found!")
                handler(nil, "Data capture error")
                return
            }
            guard let photos = photodictionary["photo"] as? [[String: AnyObject]] else {
                print("No photos were found!")
                handler(nil, "Data capture eror")
                return
            }
            handler(photos, nil)
           
            
        }
            task.resume()
        }
       
        }
    

