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
            if let device = self.device {
                self.nameLabel.text = device.peripheral.name
                self.RSSILabel.text = "\(device.RSSI) db"
                device.observeRSSIWithCallback { [weak self] (RSSI) -> Void in
                    self?.RSSILabel.text = "\(RSSI) db"
                }
            } else {
                self.nameLabel.text = ""
                self.RSSILabel.text = "0 db"
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var RSSILabel: UILabel!
    
    
    
}
