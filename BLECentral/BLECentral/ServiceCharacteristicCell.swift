//
//  ServiceCharacteristicCell.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 30.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class ServiceCharacteristicCell: UITableViewCell {

    var characteristic: BLEPeripheralCharacteristic? = nil {
        didSet {
            self.UUIDLabel.text = characteristic?.UUID.UUIDString
            if let value = characteristic?.value {
                self.valueLabel.text = NSString(data: value, encoding: NSUTF8StringEncoding) as? String
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}
