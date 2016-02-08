//
//  BLEPeripheralService.swift
//  BLECentral
//
//  Created by Vjacheslav Volodko on 29.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreBluetooth

typealias BLEPeripheralService = CBService

typealias BLEPeripheralCharacteristic = CBCharacteristic

typealias BLEDescriptor = CBDescriptor

//class BLEPeripheralService: NSObject {
//
//    private(set) var service: CBService
//    
//    init(service: CBService) {
//        service = service
//        super.init()
//    }
//    
//}


extension NSData {
    
    func stringRepresentation() -> String {
        if let object = NSKeyedUnarchiver.unarchiveObjectWithData(self) {
            return object.description
        } else if let string = NSString(data: self, encoding: NSUTF8StringEncoding) as? String {
            return string
        } else {
            return description
        }
    }

}


extension CBUUID {
    func stringRepresentation() -> String {
        if UUIDString == CBUUIDCharacteristicFormatString {
            return "Format (\(description))"
        } else if UUIDString == CBUUIDCharacteristicUserDescriptionString {
            return "User description (\(UUIDString))"
        } else if UUIDString == CBUUIDCharacteristicAggregateFormatString {
            return "Aggregate format (\(UUIDString))"
        } else if UUIDString == CBUUIDCharacteristicExtendedPropertiesString {
            return "Extended properties (\(UUIDString))"
        } else if UUIDString == CBUUIDServerCharacteristicConfigurationString {
            return "Server configuration (\(UUIDString))"
        } else if UUIDString == CBUUIDClientCharacteristicConfigurationString {
            return "Client configuration (\(UUIDString))"
        } else {
            return UUIDString
        }
    }
}
