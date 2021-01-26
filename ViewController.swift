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

var distance: Double = 0

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
        
        // layoout constraints
        pathButton.translatesAutoresizingMaskIntoConstraints = false
        pathButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        pathButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        pathButton.heightAnchor.constraint(equalToConstant: 70)
             .isActive = true // ---- 3
        pathButton.widthAnchor.constraint(equalToConstant: 70)
             .isActive = true // ---- 4
    }

    func drawPath(){
        self.path = GMSMutablePath()

        for marker in Markers.markerArray{
            self.path?.add(marker.position)
        }
        
        self.polyline?.map = nil
        self.polyline = GMSPolyline(path: self.path)
        self.polyline!.strokeColor = UIColor(displayP3Red:115/255, green: 200/255 , blue:  153/255, alpha: 1)
        self.polyline!.strokeWidth = 5
        
        if (self.showPolyline){
            self.polyline?.map = self.view as? GMSMapView
        }
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
            Markers.markerArray.removeAll()
            
            
            for record in records{
                self.recordCount+=1
                guard let lat = record["latitude"], let long = record["longitude"], let distance = record["total_distance"] else {return }
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label.center = CGPoint(x: 110, y: 40)
                label.textAlignment = .center
                    
                label.text = "최단경로 거리: \(distance) 미터"
                self.view.addSubview(label)

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
                     marker.accessibilityValue = String(count) //path Index
                     marker.icon  = UIImage(named: "newtrash")
                     count+=1
                }
                
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

        let alert = UIAlertController(title: "쓰레기를 수거하셨나요?", message: "확인 버튼을 누르면 마커가 비활성화됩니다.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            self.tappedMarker?.icon  = UIImage(named: "untrash")
            self.tappedMarker?.isTappable = false

            //delete
            if let id: Int = Int(markerId){
                self.database.child(self.databaseName).child(String(id-1)).updateChildValues(["isDeleted":1])
                if let index: Int = Int(pathId){
                    Markers.markerArray.remove(at: index)
                }
            }
            
            //update path
            self.updatePath()
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
        if let image = UIImage(named: "pathnew") {
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        button.imageView?.clipsToBounds = true
        button.imageView?.layer.masksToBounds = true
        button.imageView?.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        //        button.frame = CGRect(x: 309, y: 535, width: 70, height: 70)
        //        button.backgroundColor = UIColor(displayP3Red:64/255, green: 179/255 , blue:  112/255, alpha: 1)
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
