//
//  CharacteristicViewController.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 02.02.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class CharacteristicViewController: UITableViewController {

    var device: BLEPeripheralDevice? = nil {
        didSet {
            self.navigationItem.title = device?.peripheral.name
        }
    }

    var characteristic: BLEPeripheralCharacteristic? = nil {
        didSet {
            self.tableView.reloadData()
            if let characteristic = self.characteristic where characteristic.properties.contains(.Notify) {
                self.device?.observeValueForCharacteristic(characteristic) { (characteristic) -> Void in
                    self.device?.fetchValueForCharacteristic(characteristic) { (characteristic) -> Void in
                        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                    }
                }
            }
        }
    }

// MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        if let characteristic = self.characteristic {
            self.device?.fetchValueForCharacteristic(characteristic) { (characteristic) -> Void in
                self.device?.fetchDescriptorsForCharacteristic(characteristic) { (characteristic) -> Void in
                    if let descriptors = characteristic.descriptors {
                        for descriptor in descriptors {
                            self.device?.fetchValueForDescriptor(descriptor) { (descriptor) -> Void in
                                self.tableView.reloadData()
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

//    // MARK: - Actions
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let serviceViewController = segue.destinationViewController as? ServiceViewController,
//            let cell = sender as? DeviceServiceCell where
//            segue.identifier == "service" {
//                serviceViewController.device = self.device
//                serviceViewController.service = cell.service
//        }
//    }

    // MARK: - TableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return self.characteristic?.descriptors?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let reuseID = "PropertyCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(reuseID)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: reuseID)
            }

            if indexPath.row == 0 {
                cell?.textLabel?.text = "UUID"
                cell?.detailTextLabel?.text = self.characteristic?.UUID.UUIDString
            } else if indexPath.row == 1 {
                cell?.textLabel?.text = "Raw value"
                cell?.detailTextLabel?.text = self.characteristic?.value?.description
            } else if indexPath.row == 2 {
                cell?.textLabel?.text = "Value"
                cell?.detailTextLabel?.text = self.characteristic?.value?.stringRepresentation()
            }

            return cell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CharacteristicDescriptorCell", forIndexPath: indexPath)
            if let cell = cell as? CharacteristicDescriptorCell {
                cell.device = self.device
                cell.descriptor = self.characteristic?.descriptors?[indexPath.row]
            }
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Characteristic"
        } else {
            return "Descriptors"
        }
    }
}
