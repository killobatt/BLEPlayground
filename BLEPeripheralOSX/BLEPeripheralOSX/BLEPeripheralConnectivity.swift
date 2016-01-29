//
//  BLEPeripheralConnectivity.swift
//  BLEPeripheralOSX
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Cocoa
import CoreBluetooth


class BLEPeripheralConnectivity: NSObject {
    
    private var peripheralManager: CBPeripheralManager! = nil
    private var services: [CBUUID: CBMutableService] = [:]
    
    override init() {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func addService(service: CBMutableService) {
        if let UUID = service.UUID {
            self.services[UUID] = service
            self.peripheralManager.addService(service)
        }
    }
    
    func startAdvertising() {
        let allServiceUUIDs = self.services.map { (_: CBUUID, service: CBMutableService) -> CBUUID in
            return service.UUID!
        }
        self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : allServiceUUIDs])
        NSLog("Starting advertising services: \(allServiceUUIDs.map { $0.UUIDString })")
    }
    
    func stopAdvertising() {
        self.peripheralManager.stopAdvertising()
        NSLog("Stopped advertising")
    }
    
}

extension BLEPeripheralConnectivity: CBPeripheralManagerDelegate {
    /*!
    *  @method peripheralManagerDidUpdateState:
    *
    *  @param peripheral   The peripheral manager whose state has changed.
    *
    *  @discussion         Invoked whenever the peripheral manager's state has been updated. Commands should only be issued when the state is
    *                      <code>CBPeripheralManagerStatePoweredOn</code>. A state below <code>CBPeripheralManagerStatePoweredOn</code>
    *                      implies that advertisement has paused and any connected centrals have been disconnected. If the state moves below
    *                      <code>CBPeripheralManagerStatePoweredOff</code>, advertisement is stopped and must be explicitly restarted, and the
    *                      local database is cleared and all services must be re-added.
    *
    *  @see                state
    *
    */
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch (peripheral.state) {
        case .Unknown:
            NSLog("Peripheral manager update state to: Unknown")
        case .Resetting:
            NSLog("Peripheral manager update state to: Resetting")
        case .Unsupported:
            NSLog("Peripheral manager update state to: Unsupported")
        case .Unauthorized:
            NSLog("Peripheral manager update state to: Unauthorized")
        case .PoweredOff:
            NSLog("Peripheral manager update state to: PoweredOff")
        case .PoweredOn:
            NSLog("Peripheral manager update state to: PoweredOn")
        }
    }
    
    /*!
    *  @method peripheralManager:willRestoreState:
    *
    *  @param peripheral   The peripheral manager providing this information.
    *  @param dict
    *
    *  @discussion
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
    /*!
    *  @method peripheralManagerDidStartAdvertising:error:
    *
    *  @param peripheral   The peripheral manager providing this information.
    *  @param error        If an error occurred, the cause of the failure.
    *
    *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
    *                      not be started, the cause will be detailed in the <i>error</i> parameter.
    *
    */
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            NSLog("Failed to start advertising, error: \(error)")
        } else {
            NSLog("Started advertising")
        }
    }
    
    /*!
    *  @method peripheralManager:didAddService:error:
    *
    *  @param peripheral   The peripheral manager providing this information.
    *  @param service      The service that was added to the local database.
    *  @param error        If an error occurred, the cause of the failure.
    *
    *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
    *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if let error = error {
            NSLog("Failed to add service: \(service), error: \(error)")
        } else {
            NSLog("Did add service: \(service.UUID.UUIDString)")
        }
    }
    
    /*!
    *  @method peripheralManager:central:didSubscribeToCharacteristic:
    *
    *  @param peripheral       The peripheral manager providing this update.
    *  @param central          The central that issued the command.
    *  @param characteristic   The characteristic on which notifications or indications were enabled.
    *
    *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
    *                          It should be used as a cue to start sending updates as the characteristic value changes.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    /*!
    *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
    *
    *  @param peripheral       The peripheral manager providing this update.
    *  @param central          The central that issued the command.
    *  @param characteristic   The characteristic on which notifications or indications were disabled.
    *
    *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    /*!
    *  @method peripheralManager:didReceiveReadRequest:
    *
    *  @param peripheral   The peripheral manager requesting this information.
    *  @param request      A <code>CBATTRequest</code> object.
    *
    *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
    *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
    *
    *  @see                CBATTRequest
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        NSLog("Got read request for characteristic: \(request.characteristic.UUID.UUIDString) of service: \(request.characteristic.service.UUID.UUIDString)")
        guard request.offset > request.characteristic.value?.length else {
            NSLog("Read request failed: invalid offset")
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.InvalidOffset)
            return
        }
        
        if let service = self.services[request.characteristic.service.UUID] {
            let filteredCharacteristics = service.characteristics?.filter { (characteristic: CBCharacteristic) -> Bool in
                return characteristic.UUID == request.characteristic.UUID
            }
            if let characteristic = filteredCharacteristics?.first {
                if let value = characteristic.value {
                    let subValue = value.subdataWithRange(NSMakeRange(request.offset, value.length - request.offset))
                    NSLog("Read request sussess, returning value: \(subValue)")
                    request.value = subValue
                    self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
                    return
                }
            }
        }
        
        NSLog("Read request failed: characteristic not found")
        self.peripheralManager.respondToRequest(request, withResult: CBATTError.AttributeNotFound)
    }
    
    /*!
    *  @method peripheralManager:didReceiveWriteRequests:
    *
    *  @param peripheral   The peripheral manager requesting this information.
    *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
    *
    *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
    *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
    *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
    *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
    *
    *  @see                CBATTRequest
    *
    */
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
    }
    
    /*!
    *  @method peripheralManagerIsReadyToUpdateSubscribers:
    *
    *  @param peripheral   The peripheral manager providing this update.
    *
    *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
    *                      ready to send characteristic value updates.
    *
    */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        
    }
    
}
