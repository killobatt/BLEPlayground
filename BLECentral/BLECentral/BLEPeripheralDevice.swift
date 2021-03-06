//
//  BLEPeripheralDevice.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEPeripheralDevice: NSObject {
    
    private(set) var peripheral: CBPeripheral
    private(set) var services: [BLEPeripheralService] = []
    var RSSI: NSNumber = 0
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }
    
    deinit {
        rssiUpdateTimer?.invalidate()
    }
    
    // MARK: - RSSI
    
    typealias RSSIObserveCallbackType = (RSSI: NSNumber?) -> Void
    private var rssiUpdateTimer: NSTimer? = nil
    private var rssiObserveCallback: RSSIObserveCallbackType? = nil
    func observeRSSIWithCallback(callback: RSSIObserveCallbackType) {
        rssiObserveCallback = callback
        if let oldTimer = rssiUpdateTimer {
            oldTimer.invalidate()
        }
        rssiUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self,
            selector: "updateRSSI:",
            userInfo: nil,
            repeats: true)
    }
    
    func updateRSSI(timer: NSTimer) {
        peripheral.readRSSI()
    }
    
    // MARK: - Service List
    
    typealias FetchServicesCallback = ([BLEPeripheralService]) -> Void
    private var fetchServicesCallback: FetchServicesCallback? = nil
    func fetchServicesListWithCallback(callback: FetchServicesCallback) {
        fetchServicesCallback = callback
        peripheral.discoverServices(nil)
    }
    
    // MARK: - Service List
    
    private var fetchIncludedServicesCallbacks: [CBUUID: FetchServicesCallback] = [:]
    func fetchIncludedServicesForService(service: BLEPeripheralService,
        withCallback callback: FetchServicesCallback) {
        fetchIncludedServicesCallbacks[service.UUID] = callback
        peripheral.discoverIncludedServices(nil, forService: service)
    }
    
    // MARK: - Characteristics List
    
    typealias CharacteristicDiscoveryCallback = (service: BLEPeripheralService) -> Void
    private var characteristicsDiscoveryCallbacks: [CBUUID: CharacteristicDiscoveryCallback] = [:]
    func fetchCharacteristicsForService(service: BLEPeripheralService,
         withCallback callback: CharacteristicDiscoveryCallback) {
        characteristicsDiscoveryCallbacks[service.UUID] = callback
        peripheral.discoverCharacteristics(nil, forService: service)
    }
    
    // MARK: - Characteristic Read Value
    
    typealias CharacteristicValueCallback = (characteristic: BLEPeripheralCharacteristic) -> Void
    private var characteristicsValueCallbacks: [CBUUID: CharacteristicValueCallback] = [:]
    func fetchValueForCharacteristic(characteristic: BLEPeripheralCharacteristic,
         withCallback callback: CharacteristicValueCallback) {
        characteristicsValueCallbacks[characteristic.UUID] = callback
        peripheral.readValueForCharacteristic(characteristic)
    }
    
    // MARK: - Characteristic Observe Value
    
    private var characteristicsValueObserveCallbacks: [CBUUID: CharacteristicValueCallback] = [:]
    func observeValueForCharacteristic(characteristic: BLEPeripheralCharacteristic,
         withCallback callback: CharacteristicValueCallback) {
        characteristicsValueObserveCallbacks[characteristic.UUID] = callback
        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
    }
    
    // MARK: - Characteristic Descriptors
    
    typealias CharacteristicDescriptorsCallback = (characteristic: BLEPeripheralCharacteristic) -> Void
    private var characteristicsDescriptorsCallbacks: [CBUUID: CharacteristicDescriptorsCallback] = [:]
    func fetchDescriptorsForCharacteristic(characteristic: BLEPeripheralCharacteristic,
         withCallback callback: CharacteristicDescriptorsCallback) {
        characteristicsDescriptorsCallbacks[characteristic.UUID] = callback
        peripheral.discoverDescriptorsForCharacteristic(characteristic)
    }
    
    typealias CharacteristicDescriptorsValueCallback = (descriptor: BLEDescriptor) -> Void
    private var characteristicsDescriptorsValueCallbacks: [CBUUID: CharacteristicDescriptorsValueCallback] = [:]
    func fetchValueForDescriptor(descriptor: BLEDescriptor,
         withCallback callback: CharacteristicDescriptorsValueCallback) {
        characteristicsDescriptorsValueCallbacks[descriptor.UUID] = callback
        peripheral.readValueForDescriptor(descriptor)
    }
    
    // MARK: - Greedy Fetch
    
    func greedyFetchAllServices() {
        fetchServicesListWithCallback { (services: [BLEPeripheralService]) -> Void in
            for service in services {
                self.greedyFetchService(service)
            }
        }
    }
    
    func greedyFetchService(service: BLEPeripheralService) {
        fetchCharacteristicsForService(service) { (service: BLEPeripheralService) -> Void in
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.properties.contains(.Read) {
                        self.fetchValueForCharacteristic(characteristic) { (characteristic) -> Void in
                        }
                    }
                    self.greedyFetchDescriptorsForCharacteristic(characteristic)
                }
            }
        }
        
        fetchIncludedServicesForService(service) { (services: [BLEPeripheralService]) -> Void in
            for includedService in services {
                self.greedyFetchService(includedService)
            }
        }
    }
    
    func greedyFetchDescriptorsForCharacteristic(characteristic: BLEPeripheralCharacteristic) {
        fetchDescriptorsForCharacteristic(characteristic) { (characteristic) -> Void in
            if let descriptors = characteristic.descriptors {
                for descriptor in descriptors {
                    self.fetchValueForDescriptor(descriptor) { (descriptor) -> Void in
                        
                    }
                }
            }
        }
    }
}



extension BLEPeripheralDevice: CBPeripheralDelegate {
    /*!
    *  @method peripheralDidUpdateName:
    *
    *  @param peripheral	The peripheral providing this update.
    *
    *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
    */
    func peripheralDidUpdateName(peripheral: CBPeripheral) {
        
    }
    
    /*!
    *  @method peripheral:didModifyServices:
    *
    *  @param peripheral			The peripheral providing this update.
    *  @param invalidatedServices	The services that have been invalidated
    *
    *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
    *						At this point, the designated <code>CBService</code> objects have been invalidated.
    *						Services can be re-discovered via @link discoverServices: @/link.
    */
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
   
    /*!
    *  @method peripheral:didReadRSSI:error:
    *
    *  @param peripheral	The peripheral providing this update.
    *  @param RSSI			The current RSSI of the link.
    *  @param error		If an error occurred, the cause of the failure.
    *
    *  @discussion			This method returns the result of a @link readRSSI: @/link call.
    */
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        self.RSSI = RSSI
        rssiObserveCallback?(RSSI: RSSI)
    }
    
    /*!
    *  @method peripheral:didDiscoverServices:
    *
    *  @param peripheral	The peripheral providing this information.
    *	@param error		If an error occurred, the cause of the failure.
    *
    *  @discussion			This method returns the result of a @link discoverServices: @/link call. \
     If the service(s) were read successfully, they can be retrieved via
    *						<i>peripheral</i>'s @link services @/link property.
    *
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        NSLog("Peripheral: \(peripheral.name)\n did discover services: \(peripheral.services), error: \(error)")
        
        if let services = peripheral.services {
            self.services = services
            fetchServicesCallback?(services)
        }
    }
    
    /*!
    *  @method peripheral:didDiscoverIncludedServicesForService:error:
    *
    *  @param peripheral	The peripheral providing this information.
    *  @param service		The <code>CBService</code> object containing the included services.
    *	@param error		If an error occurred, the cause of the failure.
    *
    *  @discussion			This method returns the result of a @link
     discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
    *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService,
         error: NSError?) {
        NSLog("Peripheral: \(peripheral.name)\n service: \(service.UUID.UUIDString) " +
            "did discover included services: \(service.includedServices)")
        
        if let callback = fetchIncludedServicesCallbacks[service.UUID],
            includedServices = service.includedServices {
            callback(includedServices)
        }
    }
    
    /*!
    *  @method peripheral:didDiscoverCharacteristicsForService:error:
    *
    *  @param peripheral	The peripheral providing this information.
    *  @param service		The <code>CBService</code> object containing the characteristic(s).
    *	@param error		If an error occurred, the cause of the failure.
    *
    *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call.
     If the characteristic(s) were read successfully,
    *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
    */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService,
         error: NSError?) {
        NSLog("Peripheral: \(peripheral.name)\n did discover characteristics: " +
            " \(service.characteristics) for service: \(service.UUID.UUIDString), error: \(error)")
        
        if let callback = characteristicsDiscoveryCallbacks[service.UUID] {
            callback(service: service)
        }
    }
    
    /*!
    *  @method peripheral:didUpdateValueForCharacteristic:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param characteristic	A <code>CBCharacteristic</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call,
     or upon receipt of a notification/indication.
    */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic,
         error: NSError?) {
        
        if let callback = characteristicsValueCallbacks[characteristic.UUID] {
            callback(characteristic: characteristic)
        }
        if let callback = characteristicsValueObserveCallbacks[characteristic.UUID] {
            callback(characteristic: characteristic)
        }
    }
    
    /*!
    *  @method peripheral:didWriteValueForCharacteristic:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param characteristic	A <code>CBCharacteristic</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call,
     when the <code>CBCharacteristicWriteWithResponse</code> type is used.
    */
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic,
         error: NSError?) {
        
    }
    
    /*!
    *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param characteristic	A <code>CBCharacteristic</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
    */
    func peripheral(peripheral: CBPeripheral,
         didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
    }
    
    /*!
    *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param characteristic	A <code>CBCharacteristic</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link 
     call. If the descriptors were read successfully,
    *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
    */
    func peripheral(peripheral: CBPeripheral,
         didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let callback = characteristicsDescriptorsCallbacks[characteristic.UUID] {
            callback(characteristic: characteristic)
        }
    }
    
    /*!
    *  @method peripheral:didUpdateValueForDescriptor:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param descriptor		A <code>CBDescriptor</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
    */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        if let callback = characteristicsDescriptorsValueCallbacks[descriptor.UUID] {
            callback(descriptor: descriptor)
        }
    }
    
    /*!
    *  @method peripheral:didWriteValueForDescriptor:error:
    *
    *  @param peripheral		The peripheral providing this information.
    *  @param descriptor		A <code>CBDescriptor</code> object.
    *	@param error			If an error occurred, the cause of the failure.
    *
    *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
    */
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        
    }
}
