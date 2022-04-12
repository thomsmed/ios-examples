//
//  ChatServiceFactory.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/01/2022.
//

import Foundation
import CoreBluetooth

enum ChatServiceFactory {

    // Characteristic Format String Descriptor for Incoming Reactions Characteristic and Outgoing Reactions Characteristic
    // More Info in the Core BLE Specification: https://www.bluetooth.com/specifications/specs/core-specification/
    // TODO: Link/pointer to where this is in the specification
    private static let characteristicFormatStringValue: [UInt8] = [
        0x19, // Format: UTF8
        0x00, // Exponent: 0 (not used for the UTF8 format)
        0x27, 0x00, // Unit (4 bytes): undefined (text has no unit)
        0x00, // Name Space (Aka organisation): none
        0x00, 0x00 // Description (a custom value defined by the organisation in Name Space): none
    ]

    static let incomingReactionCharacteristic: CBMutableCharacteristic = {
        let characteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceIncomingReactionsCharacteristic,
            properties: [.write, .writeWithoutResponse],
            // Dynamic value - require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: nil,
            permissions: [.writeable] // Do not require encryption
        )
        characteristic.descriptors = [
            CBMutableDescriptor(type: CBUUID(string: CBUUIDCharacteristicUserDescriptionString), value: "IncomingReactions"),
            CBMutableDescriptor(type: CBUUID(string: CBUUIDCharacteristicFormatString), value: Data(characteristicFormatStringValue))
        ]
        return characteristic
    }()

    static let outgoingReactionsCharacteristic: CBMutableCharacteristic = {
        let characteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceOutgoingReactionsCharacteristic,
            properties: [.read, .notify],
            // Dynamic value - require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: nil,
            permissions: [.readable] // Do not require encryption
        )
        characteristic.descriptors = [
            CBMutableDescriptor(type: CBUUID(string: CBUUIDCharacteristicUserDescriptionString), value: "OutgoingReactions"),
            CBMutableDescriptor(type: CBUUID(string: CBUUIDCharacteristicFormatString), value: Data(characteristicFormatStringValue))
        ]
        return characteristic
    }()

    static func make(with psm: CBL2CAPPSM) -> CBMutableService {
        let mutableService = CBMutableService(type: AssignedNumbers.chatService, primary: true)
        let l2capPSMCharacteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceL2CAPPSMCharacteristic,
            properties: [.read],
            // Static value - do not require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: Data(withUnsafeBytes(of: psm, Array.init)),
            permissions: [.readEncryptionRequired] // Require encryption
        )
        mutableService.characteristics = [
            ChatServiceFactory.incomingReactionCharacteristic,
            ChatServiceFactory.outgoingReactionsCharacteristic,
            l2capPSMCharacteristic
        ]
        return mutableService
    }
}
