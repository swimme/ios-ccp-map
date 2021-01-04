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
    let databaseName: String = "objects"
    var objects: [[String:Int]]! = []

    // marker handling
    var tappedMarker: GMSMarker?
    var markerIndex: Int = 0 // marker key for updates

    override func viewDidLoad() {
        super.viewDidLoad()

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

        //TODO: polylines
    }

    //MARK: Load Data
    func configureDatabase() {
        databaseHandler = self.database.child(databaseName).observe(.value, with: { (snapshot) -> Void in
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
                guard let markerId: Int = record["class_id"] as? Int else { return }
                marker.snippet = String(markerId)

                if let isDeleted: Int = record["isDeleted"] as? Int {
                    if (isDeleted == 1){
                        marker.icon = GMSMarker.markerImage(with: UIColor.lightGray)
                        marker.isTappable = false
                    }
                }
                marker.map = self.view as? GMSMapView
            }
            print(records.count)
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

}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

