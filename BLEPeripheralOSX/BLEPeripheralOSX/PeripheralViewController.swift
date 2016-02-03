//
//  ViewController.swift
//  BLEPeripheralOSX
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Cocoa
import CoreBluetooth

class PeripheralWindowController: NSWindowController {

    var bluetoothEngine: BLEPeripheralConnectivity? = nil
    
    override func windowDidLoad() {
        
        super.windowDidLoad()

        self.bluetoothEngine = BLEPeripheralConnectivity()
        
        
        let launchTimeCharacteristicUserDescriptorUUID = CBUUID(string: CBUUIDCharacteristicUserDescriptionString)
        let launchTimeCharacteristicUserDescriptorValue = "Launch time"
        let launchTimeCharacteristicUserDescriptor = CBMutableDescriptor(type: launchTimeCharacteristicUserDescriptorUUID,
            value: launchTimeCharacteristicUserDescriptorValue)
        
        let characteristicType = CBUUID(string: "414737A1-E2C5-4EF9-9FF2-0F682D892733")
        let launchTimeCharacteristic = CBMutableCharacteristic(type: characteristicType,
            properties: [.Read],
            value: nil, permissions: [.Readable])
        launchTimeCharacteristic.value = NSKeyedArchiver.archivedDataWithRootObject(NSDate())
        launchTimeCharacteristic.descriptors = [launchTimeCharacteristicUserDescriptor]
        
        
        let serviceType = CBUUID(string: "F6ED52C6-8B8D-404A-B54E-30DCDDB86238")
        let service = CBMutableService(type: serviceType, primary: true)
        service.characteristics = [launchTimeCharacteristic]
        
        self.bluetoothEngine?.addService(service)
        
    }

    deinit {
        NSLog("PeripheralWindowController Deinit")
    }
}

