//
//  DeviceViewController.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class DeviceViewController: UITableViewController {
    
    var device: BLEPeripheralDevice? = nil {
        didSet {
            self.navigationItem.title = device?.peripheral.name
        }
    }
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.device?.fetchServicesListWithCallback { (services: [BLEPeripheralService]) -> Void in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let serviceViewController = segue.destinationViewController as? ServiceViewController,
            let cell = sender as? DeviceServiceCell where
            segue.identifier == "service" {
                serviceViewController.device = self.device
                serviceViewController.service = cell.service
        }
    }
    
    // MARK: - TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.device?.services.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceServiceCell", forIndexPath: indexPath) as! DeviceServiceCell
        cell.service = self.device?.services[indexPath.row]
        return cell
    }
    
}
