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
            if let characteristic = characteristic {
                UUIDLabel.text = characteristic.UUID.UUIDString
                if let value = characteristic.value {
                    setCharacteristicValue(value)
                } else if let device = device {
                    device.fetchValueForCharacteristic(characteristic) { (characteristic) -> Void in
                        self.setCharacteristicValue(characteristic.value)
                    }
                }
            }
        }
    }

    private func setCharacteristicValue(value: NSData?) {
        valueLabel.text = value?.stringRepresentation()
    }

    // MARK: - IBOutlets
    
    // swiftlint:disable variable_name
    @IBOutlet weak var UUIDLabel: UILabel!
    // swiftlint:enable variable_name
    @IBOutlet weak var valueLabel: UILabel!
    
}
