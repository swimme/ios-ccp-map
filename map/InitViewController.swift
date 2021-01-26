//
//  InitViewController.swift
//  map
//
//  Created by Swimme on 2021/01/27.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit

class InitViewController: UIViewController {

    var gradientLayer: CAGradientLayer!
    
    @objc func myMethod() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mapView") as! ViewController
    //            self.present(vc, animated: false, completion: nil)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(myMethod), userInfo: nil, repeats: false)

    }

        
//        
//        self.gradientLayer = CAGradientLayer()
//        self.gradientLayer.frame = self.view.bounds
//        self.gradientLayer.colors = [ UIColor(red:64/255, green: 179/255 , blue:  112/255, alpha: 0.5),UIColor.systemTeal.cgColor ]
//        self.view.layer.addSublayer(self.gradientLayer)
//        myMethod()
//        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "NextViewController") as! ViewController
//         self.present(myVC, animated: true, completion: nil)
    


}
