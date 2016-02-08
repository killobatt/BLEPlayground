//
//  DeviceDiscoveryTableViewCell.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 28.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class DeviceDiscoveryTableViewCell: UITableViewCell {

    var device: BLEPeripheralDevice? = nil {
        didSet {
            if let device = device {
                nameLabel.text = device.peripheral.name
                RSSILabel.text = "\(device.RSSI) db"
                device.observeRSSIWithCallback { [weak self] (RSSI: NSNumber?) -> Void in
                    if let RSSI = RSSI {
                        self?.RSSILabel.text = "\(RSSI) db"
                    }
                }
            } else {
                nameLabel.text = ""
                RSSILabel.text = "0 db"
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    // swiftlint:disable variable_name
    @IBOutlet weak var RSSILabel: UILabel!
    // swiftlint:enable variable_name
    
}
