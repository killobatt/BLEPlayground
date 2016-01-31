//
//  ServiceViewController.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 30.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class ServiceViewController: UITableViewController {

    var device: BLEPeripheralDevice? = nil {
        didSet {
            self.navigationItem.title = device?.peripheral.name
        }
    }
    var service: BLEPeripheralService? = nil
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let device = self.device,
            let service = self.service {
                device.fetchCharacteristicsForService(service) { (service: BLEPeripheralService) -> Void in
                    self.tableView.reloadData()
                }
        }
    }
    
    // MARK: - TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.service?.includedServices?.count ?? 0
        } else if section == 2 {
            return self.service?.characteristics?.count ?? 0
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 || indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DeviceServiceCell", forIndexPath: indexPath) as! DeviceServiceCell
            if (indexPath.section == 0) {
                cell.service = self.service
            } else {
                cell.service = self.service?.includedServices?[indexPath.row]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCharacteristicCell", forIndexPath: indexPath) as! ServiceCharacteristicCell
            cell.device = self.device
            cell.characteristic = self.service?.characteristics?[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Service"
        } else if section == 1 {
            return "Included services"
        } else {
            return "Characteristics"
        }
    }
}
