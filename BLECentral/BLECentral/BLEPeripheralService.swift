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
//        self.service = service
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
            return self.description
        }
    }

}


extension CBUUID {
    func stringRepresentation() -> String {
        if self.UUIDString == CBUUIDCharacteristicFormatString {
            return "Format (\(self.description))"
        } else if self.UUIDString == CBUUIDCharacteristicUserDescriptionString {
            return "User description (\(self.UUIDString))"
        } else if self.UUIDString == CBUUIDCharacteristicAggregateFormatString {
            return "Aggregate format (\(self.UUIDString))"
        } else if self.UUIDString == CBUUIDCharacteristicExtendedPropertiesString {
            return "Extended properties (\(self.UUIDString))"
        } else if self.UUIDString == CBUUIDServerCharacteristicConfigurationString {
            return "Server configuration (\(self.UUIDString))"
        } else if self.UUIDString == CBUUIDClientCharacteristicConfigurationString {
            return "Client configuration (\(self.UUIDString))"
        } else {
            return self.UUIDString
        }
    }
}
