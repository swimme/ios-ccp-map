//
//  CustomInfoWindow.swift
//  map
//
//  Created by YOUNG on 2020/08/27.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {
    
    @IBOutlet weak var customWindowLabel: UILabel!
    @IBOutlet var customWindowButton: UIButton!
    
    var view:UIView!
    
//    @IBAction func press(_ sender: UIButton) {
//     self.customWindowLabel.text = "You just pressed the button ! "
//    }
    
    // initialize view
    override init(frame: CGRect) {
     super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
    }
    
    // load using file name "CustomInfoWIndow"
    func loadView() -> CustomInfoWindow{
     let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
     return customInfoWindow
    }

    
}
