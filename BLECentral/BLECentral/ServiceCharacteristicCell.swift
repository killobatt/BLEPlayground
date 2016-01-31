//
//  ServiceCharacteristicCell.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 30.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class ServiceCharacteristicCell: UITableViewCell {

    var device: BLEPeripheralDevice? = nil
    var characteristic: BLEPeripheralCharacteristic? = nil {
        didSet {
            if let characteristic = self.characteristic {
                self.UUIDLabel.text = characteristic.UUID.UUIDString
                if let value = characteristic.value {
                    self.setCharacteristicValue(value)
                } else if let device = self.device {
                    device.fetchValueForCharacteristic(characteristic) { (characteristic) -> Void in
                        self.setCharacteristicValue(characteristic.value)
                    }
                }
            }
        }
    }

    private func setCharacteristicValue(value: NSData?) {
        if let value = value {
            self.valueLabel.text = NSString(data: value, encoding: NSUTF8StringEncoding) as? String
        }
    }

    // MARK: - IBOutlets
    
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
}
