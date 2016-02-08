//
//  CharacteristicDescriptorCell.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 02.02.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class CharacteristicDescriptorCell: UITableViewCell {
    
    var device: BLEPeripheralDevice? = nil
    var descriptor: BLEDescriptor? = nil {
        didSet {
            if let descriptor = descriptor {
                UUIDLabel.text = descriptor.UUID.stringRepresentation()
                if let value = descriptor.value {
                    valueLabel.text = value.description
                } else if let device = device {
                    device.fetchValueForDescriptor(descriptor) { (descriptor) -> Void in
                       self.valueLabel.text = descriptor.value?.description
                    }
                }
            }
        }
    }
    
    
    // MARK: - IBOutlets
    
    // swiftlint:disable variable_name
    @IBOutlet weak var UUIDLabel: UILabel!
    // swiftlint:enable variable_name
    @IBOutlet weak var valueLabel: UILabel!

}
