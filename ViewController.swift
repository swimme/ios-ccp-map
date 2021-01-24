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

struct A{
    static var positionArray = Array<CLLocationCoordinate2D>()
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
        
        // :CLUSTER
    }

    //MARK: Load Data
    func configureDatabase() {
        databaseHandler = self.database.child(databaseName).observe(.value, with: { (snapshot) -> Void in
            guard let records = snapshot.value as? [[String: Any]] else { return }
            
            // show Markers
            for record in records{
                guard let lat = record["latitude"], let long = record["longitude"] else {return }

                let marker: GMSMarker = GMSMarker()
                let position: CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: lat as! CLLocationDegrees, longitude: long  as! CLLocationDegrees)
                marker.position = position
                
//                guard let markerId: Int = record["id"] as? Int else { return }
//                marker.snippet = String(markerId)

                if let isDeleted: Int = record["isDeleted"] as? Int {
                    if (isDeleted == 1){
                        marker.icon = GMSMarker.markerImage(with: UIColor.lightGray)
                        marker.isTappable = false
                    }
                }
                // cluster - not here
//                self.clusterManager.add(marker)
                marker.map = self.view as? GMSMapView
                
                // path 추가
                A.positionArray.append(position)
            }
            print(records.count)
            
            // path 설정
            self.path = GMSMutablePath()
            for position in A.positionArray{
                self.path?.add(position)
            }
            
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
        // :CLUSTER
        // check if a cluster icon was tapped
        print("marker was tapped")
        
        tappedMarker = marker
        let markerId: String! = tappedMarker?.snippet
        let alert = UIAlertController(title: "쓰레기를 수거하셨나요?", message: "확인 버튼을 누르면 마커가 비활성화됩니다.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            //db update
            self.database.child(self.databaseName).queryOrdered(byChild: "class_id").queryEqual(toValue: Int(markerId)).observeSingleEvent(of: .childAdded) { (snapshot) in
                let newRef = snapshot.ref.child("isDeleted")
                newRef.setValue(true)
            }
            self.tappedMarker?.icon = GMSMarker.markerImage(with: UIColor.lightGray)
            self.tappedMarker?.isTappable = false
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
        button.setTitle("Btn", for: UIControl.State.normal)
        button.layer.cornerRadius = 5.0;
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)

        return button
    }

    @IBAction func buttonClicked(_ sender: UIButton) {
        if (!showPolyline) {
            polyline = GMSPolyline(path: self.path)
            polyline!.strokeColor = UIColor(red: 0, green: 191/255.0, blue: 1, alpha: 0.8)
            polyline!.strokeWidth = 5
            polyline!.map = self.view as? GMSMapView
            showPolyline = true
            return
        }
        showPolyline = false
        polyline!.map = nil
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

