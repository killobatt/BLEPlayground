//
//  BLECentralConnectivity.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentralConnectivity: NSObject {
    
    private var centralManager: CBCentralManager! = nil
    private(set) var discoveredDevices: [BLEPeripheralDevice] = []
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private var discoveredDeviceCallback: ((BLEPeripheralDevice) -> Void)? = nil
    private var shouldStartScan = false
    
    func scanForDevicesWithCallback(callback: (newDevice: BLEPeripheralDevice) -> Void) {
        self.discoveredDeviceCallback = callback
        
        if (self.centralManager.state == .PoweredOn) {
            NSLog("Started scanning for peripherals...")
            self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        } else {
            self.shouldStartScan = true
        }
    }
    
    func connectDevice(device: BLEPeripheralDevice) {
        self.centralManager.connectPeripheral(device.peripheral, options: nil)
    }
    
    func disconnectDevice(device: BLEPeripheralDevice) {
        self.centralManager.cancelPeripheralConnection(device.peripheral)
    }
}


// MARK: - CBCentralManagerDelegate
extension BLECentralConnectivity: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .Unknown:
            NSLog("Unknown")
        case .Resetting:
            NSLog("Resetting")
        case .Unsupported:
            NSLog("Unsupported")
        case .Unauthorized:
            NSLog("Unauthorized")
        case .PoweredOff:
            NSLog("PoweredOff")
        case .PoweredOn:
            NSLog("PoweredOn")
            if (self.shouldStartScan) {
                NSLog("Started scanning for peripherals...")
                self.centralManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
                self.shouldStartScan = false
            }
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        NSLog("Did discover peripheral: \(peripheral)\n advertisement data: \(advertisementData)\n RSSI: \(RSSI)")
        let discoveredPeripherals = self.discoveredDevices.map { $0.peripheral }
        if let index = discoveredPeripherals.indexOf(peripheral) {
            let device = self.discoveredDevices[index]
            device.RSSI = RSSI
            self.discoveredDeviceCallback?(device)
        } else {
            let newDevice = BLEPeripheralDevice(peripheral: peripheral)
            newDevice.RSSI = RSSI
            self.discoveredDevices.append(newDevice)
            self.discoveredDeviceCallback?(newDevice)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        NSLog("Connected peripheral: \(peripheral)")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Failed to connected peripheral: \(peripheral), error: \(error)")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Disconnected peripheral: \(peripheral)")
    }
}