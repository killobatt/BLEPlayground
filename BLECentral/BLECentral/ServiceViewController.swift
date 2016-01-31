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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.service?.characteristics?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServiceCharacteristicCell", forIndexPath: indexPath) as! ServiceCharacteristicCell
        cell.device = self.device
        cell.characteristic = self.service?.characteristics?[indexPath.row]
        return cell
    }
}
