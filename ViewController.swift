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

struct Path{
    static var positionArray = Array<CLLocationCoordinate2D>()
}

struct Markers{
    static var markerArray = Array<GMSMarker>()
}


public let DATUM_POINT = CLLocation(latitude: 37.590597, longitude: 127.035898)

class ViewController: UIViewController, GMSMapViewDelegate {

    // MARK: Properties
    @IBOutlet var mapView: GMSMapView!
    var pathButton: UIButton!
    
    // database
    var database: DatabaseReference = Database.database().reference()
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "cities"
    var objects: [[String:Int]]! = []
    var recordCount: Int = 0

    // marker handler
    var tappedMarker: GMSMarker?
    var markerIndex: Int = 0 // marker key for updates
    
    // path handler
    var path:GMSMutablePath?
    var polyline: GMSPolyline?
    var showPolyline: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // inital camera frame
        let camera = GMSCameraPosition.camera(withLatitude: DATUM_POINT.coordinate.latitude, longitude: DATUM_POINT.coordinate.longitude, zoom: 14.5)

        // 초기 설정
        let rect = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        view = mapView
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self

        configureDatabase()

        // track tappedMarker
        self.tappedMarker = GMSMarker()
        
        // add path button
        pathButton = createCustomButton()
        self.view.addSubview(pathButton)
    }

    func drawPath(){
      self.path = GMSMutablePath()
      for marker in Markers.markerArray{
        self.path?.add(marker.position)
      }
      self.polyline = GMSPolyline(path: self.path)
      self.polyline!.strokeColor = UIColor(displayP3Red:115/255, green: 200/255 , blue:  153/255, alpha: 1)
      self.polyline!.strokeWidth = 5
    }
    
    func updatePath() {
        var count = 0
        for marker in Markers.markerArray{
            marker.accessibilityValue = String(count) //path Index
            count = count+1
        }
    }
    
    //MARK: Load Data
    func configureDatabase() {
        databaseHandler = self.database.child(databaseName).observe(.value, with: { (snapshot) -> Void in
            guard let records = snapshot.value as? [[String: Any]] else { return }
            
            if (records.count == self.recordCount){
                print("all")
                return
            }
            
            //init
            var count = 0
//            Path.positionArray.removeAll()
            Markers.markerArray.removeAll()
            
            for record in records{
                self.recordCount+=1
                guard let lat = record["latitude"], let long = record["longitude"] else {return }
               
                let marker: GMSMarker = GMSMarker()
                let position: CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: lat as! CLLocationDegrees, longitude: long  as! CLLocationDegrees)
                
                guard let markerId: Int = record["id"] as? Int else { return }
                marker.position = position
                marker.snippet = String(markerId)

                if let _:Int = record["isDeleted"] as? Int {
                     marker.icon = UIImage(named: "untrash")
                     marker.isTappable = false
                }else{
                     Markers.markerArray.append(marker)
//                     Path.positionArray.append(position)
                     marker.accessibilityValue = String(count) //path Index
                     marker.icon  = UIImage(named: "trash")
                     count+=1
                }
                
//                print(markerId, marker.accessibilityValue)
                marker.map = self.view as? GMSMapView
            }
            print(records.count)
            self.drawPath()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: MarkerTap Event
    //empty default
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        let markerId: String! = tappedMarker?.snippet
        let pathId: String! = self.tappedMarker?.accessibilityValue
//        print("tapped",markerId,pathId)

        let alert = UIAlertController(title: "쓰레기를 수거하셨나요?", message: "확인 버튼을 누르면 마커가 비활성화됩니다.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            self.tappedMarker?.icon  = UIImage(named: "untrash")
            self.tappedMarker?.isTappable = false

            //delete
            if let id: Int = Int(markerId){
                self.database.child(self.databaseName).child(String(id-1)).updateChildValues(["isDeleted":1])
                if let index: Int = Int(pathId){
//                    Path.positionArray.remove(at: index)
                    Markers.markerArray.remove(at: index)
                }
            }
            
            //update path
            self.updatePath()
            self.polyline?.map = nil
            self.showPolyline = false
            self.drawPath()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler : nil)
        alert.addAction(cancel)
        alert.addAction(okAction)
        present(alert, animated: true)

        return false
    }

    
    //MARK : SHOW PATH BUTTON
    func createCustomButton() -> UIButton? {
        let button: UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        button.frame = CGRect(x: 290, y: 550, width: 50, height: 36)
        button.setTitle("길찾기", for: UIControl.State.normal)
//        button.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControl.State#>)
        button.layer.cornerRadius = 5.0;
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)

        return button
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        if (!showPolyline) {
            self.polyline?.map = self.view as? GMSMapView
            showPolyline = true
            return
        }
        self.polyline?.map = nil
        showPolyline = false
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
