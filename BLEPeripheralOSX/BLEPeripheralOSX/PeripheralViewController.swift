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
    
    var clockCharacteristic: CBMutableCharacteristic? = nil
    var clockTimer: NSTimer? = nil
    
    override func windowDidLoad() {
        
        super.windowDidLoad()

        self.bluetoothEngine = BLEPeripheralConnectivity()
        
        
        let launchTimeCharacteristicUserDescriptorUUID = CBUUID(string: CBUUIDCharacteristicUserDescriptionString)
        let launchTimeCharacteristicUserDescriptorValue = "Launch time"
        let launchTimeCharacteristicUserDescriptor = CBMutableDescriptor(type: launchTimeCharacteristicUserDescriptorUUID,
            value: launchTimeCharacteristicUserDescriptorValue)
        
        let launchTimecharacteristicType = CBUUID(string: "414737A1-E2C5-4EF9-9FF2-0F682D892733")
        let launchTimeCharacteristic = CBMutableCharacteristic(type: launchTimecharacteristicType,
            properties: [.Read],
            value: nil, permissions: [.Readable])
        launchTimeCharacteristic.value = NSKeyedArchiver.archivedDataWithRootObject(NSDate())
        launchTimeCharacteristic.descriptors = [launchTimeCharacteristicUserDescriptor]
        
        
        let clockCharacteristicUserDescriptorUUID = CBUUID(string: CBUUIDCharacteristicUserDescriptionString)
        let clockCharacteristicUserDescriptorValue = "Clock"
        let clockCharacteristicUserDescriptor = CBMutableDescriptor(type: clockCharacteristicUserDescriptorUUID,
            value: clockCharacteristicUserDescriptorValue)
        
        let clockCharacteristicType = CBUUID(string: "C436AC67-9F54-4C58-9AEB-838F24AE2F99")
        self.clockCharacteristic = CBMutableCharacteristic(type: clockCharacteristicType,
            properties: [.Notify],
            value: nil, permissions: [.Readable])
        self.clockCharacteristic?.descriptors = [clockCharacteristicUserDescriptor]
        self.clockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerEvent:", userInfo: nil, repeats: true)

        
        let serviceType = CBUUID(string: "F6ED52C6-8B8D-404A-B54E-30DCDDB86238")
        let service = CBMutableService(type: serviceType, primary: true)
        service.characteristics = [launchTimeCharacteristic, self.clockCharacteristic!]
        
        self.bluetoothEngine?.addService(service)
        
    }

    deinit {
        NSLog("PeripheralWindowController Deinit")
    }
    
    func timerEvent(timer: NSTimer) {
        if let clockCharacteristic = self.clockCharacteristic {
            clockCharacteristic.value = NSKeyedArchiver.archivedDataWithRootObject(NSDate())
            self.bluetoothEngine?.notifySubscribersForCharacteristic(clockCharacteristic)
        }
    }
}

