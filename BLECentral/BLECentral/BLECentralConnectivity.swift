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
    
    private let knownDevicesDefaultsKey = "knownDevices"
    private(set) var knownDevicesUUIDs: [NSUUID] {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let deviceUUIDs = defaults.objectForKey(knownDevicesDefaultsKey) as? [NSUUID] {
                return deviceUUIDs
            } else {
                return []
            }
        }
        set (newValue) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: knownDevicesDefaultsKey)
            defaults.synchronize()
        }
    }
    
    override init() {
        super.init()
        let options = [CBCentralManagerOptionRestoreIdentifierKey : "BLECentralConnectivity"]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    private var discoveredDeviceCallback: ((BLEPeripheralDevice) -> Void)? = nil
    private var shouldStartScan = false
    
    func scanForDevicesWithCallback(callback: (newDevice: BLEPeripheralDevice) -> Void) {
        discoveredDeviceCallback = callback
        
        if centralManager.state == .PoweredOn {
            NSLog("Started scanning for peripherals...")
            let scanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey:false]
            centralManager?.scanForPeripheralsWithServices(nil, options: scanOptions)
        } else {
            shouldStartScan = true
        }
    }
    
    func reconnectKnownDevicesWithCallback(callback: (reconnectedDevices: [BLEPeripheralDevice]) -> Void) {
        let peripherals = centralManager.retrievePeripheralsWithIdentifiers(knownDevicesUUIDs)
        let devices = peripherals.map { peripheral in BLEPeripheralDevice(peripheral: peripheral) }
        
        discoveredDevices.appendContentsOf(devices)
        callback(reconnectedDevices: devices)
    }
    
    func connectDevice(device: BLEPeripheralDevice) {
        if device.peripheral.state == .Disconnected {
            centralManager.connectPeripheral(device.peripheral, options: nil)
        }
    }
    
    func disconnectDevice(device: BLEPeripheralDevice) {
        centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    
    // MARK: - Utility
    private func discoveredDeviceForPeripheral(peripheral: CBPeripheral) -> BLEPeripheralDevice? {
        let discoveredPeripherals = discoveredDevices.map { $0.peripheral }
        if let index = discoveredPeripherals.indexOf(peripheral) {
            return discoveredDevices[index]
        } else {
            return nil
        }
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
            if shouldStartScan {
                NSLog("Started scanning for peripherals...")
                centralManager?.scanForPeripheralsWithServices(nil,
                    options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
                shouldStartScan = false
            }
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState state: [String : AnyObject]) {
        if let peripherals = state[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                let restoredDevice = BLEPeripheralDevice(peripheral: peripheral)
                discoveredDevices.append(restoredDevice)
                discoveredDeviceCallback?(restoredDevice)
            }
        }
    }

    func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject], RSSI: NSNumber) {
        NSLog("Did discover peripheral: \(peripheral)\n advertisement data: \(advertisementData)\n RSSI: \(RSSI)")
        if let device = discoveredDeviceForPeripheral(peripheral) {
            device.RSSI = RSSI
            discoveredDeviceCallback?(device)
        } else {
            let newDevice = BLEPeripheralDevice(peripheral: peripheral)
            newDevice.RSSI = RSSI
            discoveredDevices.append(newDevice)
            discoveredDeviceCallback?(newDevice)
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        NSLog("Connected peripheral: \(peripheral)")
        if let device = discoveredDeviceForPeripheral(peripheral) {
            device.greedyFetchAllServices()
            knownDevicesUUIDs.append(device.peripheral.identifier)
        } else {
            NSLog("Weird: connected not discovered device")
        }
    }

    func centralManager(central: CBCentralManager,
        didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Failed to connected peripheral: \(peripheral), error: \(error)")
        let discoveredPeripherals = discoveredDevices.map { $0.peripheral }
        if let index = discoveredPeripherals.indexOf(peripheral) {
            discoveredDevices.removeAtIndex(index)
        }
    }

    func centralManager(central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Disconnected peripheral: \(peripheral)")
    }
}
