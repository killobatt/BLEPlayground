//
//  DeviceServiceCell.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class DeviceServiceCell: UITableViewCell {
    
    var service: BLEPeripheralService? = nil {
        didSet {
            self.UUIDLabel.text = service?.UUID.UUIDString
        }
    }
    
    // MARK: - IBOutlets
    
    // swiftlint:disable variable_name
    @IBOutlet weak var UUIDLabel: UILabel!
    // swiftlint:enable variable_name
    
}
