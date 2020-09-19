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


public let DATUM_POINT = CLLocation(latitude: 37.522979, longitude: 126.955416)

class ViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: Properties
    @IBOutlet var mapView: GMSMapView!
    
    // database
    var database: DatabaseReference = Database.database().reference()
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "0"
    let recordName: String = "objects"
    var objects: [[String:Int]]! = []
    
    // marker handling
    var tappedMarker: GMSMarker?
    var customInfoWindow: CustomInfoWindow?
    var markerIndex: Int = 0 // marker key for updates
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
        
        // inital camera frame
        let camera = GMSCameraPosition.camera(withLatitude: DATUM_POINT.coordinate.latitude, longitude: DATUM_POINT.coordinate.longitude, zoom: 14.5)
        
        //초기 설정 (editing 필요 x)
        let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        view = mapView
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        configureDatabase()
        
        //track tappedMarker
        self.tappedMarker = GMSMarker()
        self.customInfoWindow = CustomInfoWindow().loadView()
        
        
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
    
    //MARK: Load Data
    func configureDatabase() {
//        database = Database.database().reference()
        databaseHandler = self.database.child(databaseName).child(recordName)
            .observe(.value, with: { (snapshot) -> Void in
                guard let records = snapshot.value as? [[String: Any]] else { return }
                
                // show Markers
                for record in records{
                    guard let object = record["relative_coordinates"] as? [String: Int], let lat = object["top_y"], let long = object["left_x"] else {return }
                    
                    let scale: Double = 0.000002 // 축척
                    let marker: GMSMarker = GMSMarker()
                    let realLat = Double(lat) * scale
                    let realLong = Double(long) * scale
                    let position: CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: DATUM_POINT.coordinate.latitude-realLat, longitude: DATUM_POINT.coordinate.longitude+realLong)
                    marker.position = position
//                    marker.snippet = record["class_id"] as? String
                    
                    //TODO: fix logic..? object id
                    marker.snippet = "\(self.markerIndex)"
                    self.markerIndex += 1
                    
                    if let isDeleted: Int = record["isDeleted"] as? Int {
                        if (isDeleted == 1){
                            marker.icon = GMSMarker.markerImage(with: UIColor.lightGray)
                            marker.isTappable = false
                        }
                    }
                    marker.map = self.view as? GMSMapView
                    print(self.markerIndex)
                }
                self.markerIndex  = 0
            }) { (error) in
                print(error.localizedDescription) //db server error
        }
       
    }
    
    //MARK: Custom MarkerInfo window
    //empty default
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("marker was tapped")
        tappedMarker = marker
        
        // customInfoWindow 삭제-> 바로 button으로 수정
        //        customInfoWindow?.customWindowLabel.text = marker.title
        //        let opaqueWhite = UIColor(white: 1, alpha: 0.85)
        //        customInfoWindow?.layer.backgroundColor = opaqueWhite.cgColor
        //        customInfoWindow?.layer.cornerRadius = 8
        //        customInfoWindow?.customWindowButton.addTarget(self, action: #selector(self.press), for: .touchUpInside)
        //        self.view.addSubview(customInfoWindow!)
        
        let markerId: String! = tappedMarker?.snippet
        let updates: [String:Any] = ["isDeleted":1]
        let alert = UIAlertController(title: "쓰레기를 수거하셨나요?", message: "확인 버튼을 누르면 마커가 비활성화됩니다.", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            self.database.child(self.databaseName).child(self.recordName).child(markerId).updateChildValues(updates)
//            self.customInfoWindow?.removeFromSuperview()
            
            //TODO: reload logic re
            self.tappedMarker?.icon = GMSMarker.markerImage(with: UIColor.lightGray)
            self.tappedMarker?.isTappable = false
            print("reload?")
            mapView.clear()
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler : nil)
        alert.addAction(cancel)
        alert.addAction(okAction)
        
        present(alert, animated: true)
        
        return false
    }
    
    /* button logic in customInfoWindow
      // disable marker
      @objc func press(_ sender: UIButton) {
          let markerId: String! = tappedMarker?.snippet
          let updates: [String:Any] = ["isDeleted":1]
          
          //alert
          let alert = UIAlertController(title: "쓰레기를 수거하셨나요?", message: "확인 버튼을 누르면 마커가 비활성화됩니다.", preferredStyle: UIAlertController.Style.alert)
          let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
              self.database.child(self.databaseName).child(self.recordName).child(markerId).updateChildValues(updates)
              self.customInfoWindow?.removeFromSuperview()
              
              self.tappedMarker?.icon = GMSMarker.markerImage(with: UIColor.lightGray)
              self.tappedMarker?.isTappable = false
          }
          let cancel = UIAlertAction(title: "취소", style: .destructive, handler : nil)
          alert.addAction(cancel)
          alert.addAction(okAction)
          
          present(alert, animated: true)
      }
     
         //follow marker
     //    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
     //        let position = tappedMarker?.position
     //        customInfoWindow?.center = mapView.projection.point(for: position!)
     //        customInfoWindow?.center.y -= 140
     //    }
         
         //close event
     //    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
     //        customInfoWindow?.removeFromSuperview()
     //    }
    */
    
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




