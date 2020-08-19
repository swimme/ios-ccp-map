//
//  ViewController.swift
//  map
//
//  Created by user on 2020/08/03.
//  Copyright © 2020 user. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseDatabase

public let DATUM_POINT = CLLocation(latitude: 37.591516, longitude: 127.029952)

class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet var mapView: GMSMapView!
    
    var database: DatabaseReference!
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "0"
    let recordName: String = "objects"
    var objects: [[String:Int]]! = []
    
   // MARK: connect Database
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName).child(recordName)
            .observe(.value, with: { (snapshot) -> Void in
                guard let records = snapshot.value as? [[String: Any]] else { return }
                
                // MARK: show Markers
                for record in records{
                    guard let object = record["relative_coordinates"] as? [String: Int], let lat = object["top_y"], let long = object["left_x"] else {return }
                    let scale: Double = 0.000002 // 축척
                    let marker: GMSMarker = GMSMarker()
                    let realLat = Double(lat) * scale
                    let realLong = Double(long) * scale
                    let position: CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: DATUM_POINT.coordinate.latitude-realLat, longitude: DATUM_POINT.coordinate.longitude+realLong)
                    marker.position = position
                    marker.map = self.view as? GMSMapView
                }
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
        
        // inital camera frame
        let camera = GMSCameraPosition.camera(withLatitude: 37.591516, longitude: 127.029952, zoom: 14.5)
        
        //초기 설정 (editing 필요 x)
        let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        view = mapView
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        configureDatabase()
        
        //TODO: polylines
        //        var list = [CLLocationCoordinate2D]()
        
        //        func add_list(_ position: CLLocationCoordinate2D){
        //                list.append(position)
        //        }
        
        //            let path = GMSMutablePath()
        //            for coord in list {
        //                path.add(coord)
        //            }
        
        //            let line = GMSPolyline(path: path)
        //            line.strokeColor = UIColor.blue
        //            line.strokeWidth = 3.0
        //            line.map = mapView
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        //lblLocation.text = "latitude = \(locValue.latitude), longitude = \(locValue.longitude)"
    }
}


/*
 func gotoMyLocationAction()
 {
 guard let lat = self.mapView.myLocation?.coordinate.latitude,
 let lng = self.mapView.myLocation?.coordinate.longitude else { return }
 
 let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: 15)
 self.mapView.animate(to: camera)
 
 }
 
*/

/*
 func showMarkers() {
           for object in objects {
               guard let lat = object["top_y"], let long = object["left_x"] else {return}
               let scale: Double = 0.000002
               let marker: GMSMarker = GMSMarker()
               let realLat = Double(lat) * scale
               let realLong = Double(long) * scale
               let position: CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: DATUM_POINT.coordinate.latitude-realLat, longitude: DATUM_POINT.coordinate.longitude+realLong)
               marker.position = position
               DispatchQueue.main.async { // Setting marker on mapview in main thread.
                   marker.map = self.view as? GMSMapView // Setting marker on Mapview
               }
           }
       }
       
       // Marking Function
       func addMarker(_ position: CLLocationCoordinate2D, _ Title: String) {
           let marker: GMSMarker = GMSMarker() // Allocating Marker
           
           marker.title = Title // Setting title
           marker.snippet = "Sub title" // Setting sub title
           marker.icon = UIImage(named: "icon") // Marker icon
           marker.appearAnimation = .pop // Appearing animation. default
           marker.position = position // CLLocationCoordinate2D
           
           DispatchQueue.main.async { // Setting marker on mapview in main thread.
               marker.map = self.view as? GMSMapView // Setting marker on Mapview
           }
       }
        
        //json Decoder
        guard let source = Bundle.main.path(forResource: "examplejson", ofType: "json")else {return}
        let url = URL(fileURLWithPath: source)
        do{
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard let array = json as? [Any] else {return}
            for user in array {
                
                guard let userDict = user as? [String:Any] else {return}
                guard let Title = userDict["title"] as? String else {return}
                guard let Latitude = userDict["latitude"] as? Double else {return}
                guard let Longitude = userDict["longitude"] as? Double else {return}
                let position = CLLocationCoordinate2DMake(Latitude ,Longitude)
                add_marker(position, Title)
                add_list(position)
                
            }
            
        }catch{
            print(error)
        }
 
 */




