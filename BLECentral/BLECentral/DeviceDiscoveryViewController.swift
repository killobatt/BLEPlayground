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
        
        centralConnectivity = BLECentralConnectivity()
    }
    
    // MARK: - IBActions
    
    @IBAction func scanPressed(sender: AnyObject) {
        centralConnectivity.scanForDevicesWithCallback { (newDevice) -> Void in
            self.centralConnectivity.connectDevice(newDevice)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func reconnectPressed(sender: AnyObject) {
        centralConnectivity.reconnectKnownDevicesWithCallback { (reconnectedDevices) in
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let deviceViewController = segue.destinationViewController as? DeviceViewController,
            let cell = sender as? DeviceDiscoveryTableViewCell where
            segue.identifier == "device" {
                deviceViewController.device = cell.device
        }
    }
    
    // MARK: - TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.centralConnectivity.discoveredDevices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeviceDiscoveryTableViewCell", forIndexPath: indexPath)
        if let cell = cell as? DeviceDiscoveryTableViewCell {
            cell.device = centralConnectivity.discoveredDevices[indexPath.row]
        }
        return cell
    }
    
}
