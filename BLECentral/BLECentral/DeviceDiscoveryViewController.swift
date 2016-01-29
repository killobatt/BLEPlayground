//
//  DeviceDiscoveryViewController.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 28.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class DeviceDiscoveryViewController: UITableViewController {
    
    var centralConnectivity: BLECentralConnectivity! = nil
    
    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.centralConnectivity = BLECentralConnectivity()
    }
    
    // MARK: - TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.centralConnectivity.discoveredDevices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("discovery", forIndexPath: indexPath) as! DeviceDiscoveryTableViewCell
        cell.device = self.centralConnectivity.discoveredDevices[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let device = self.centralConnectivity.discoveredDevices[indexPath.row]
        self.centralConnectivity.connectDevice(device)
    }
    
}

