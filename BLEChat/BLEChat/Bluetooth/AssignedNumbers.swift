//
//  AssignedNumbers.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 14/01/2022.
//

import Foundation
import CoreBluetooth

enum AssignedNumbers {
    // For a list of predefined services/profiles (by the Bluetooth SIG): https://www.bluetooth.com/specifications/assigned-numbers/
    // Apple's Core Bluetooth Programming Guide: https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html#//apple_ref/doc/uid/TP40013257-CH1-SW1
    // WWDC videos:
    // - What's new in Core Bluetooth 2017: https://developer.apple.com/videos/play/wwdc2017/712/
    // - What's new in Core Bluetooth 2019: https://developer.apple.com/videos/play/wwdc2019/901/
    
    // Identifiers for our custom service and characteristics (Chat Service)
    // - Can be any 128 bit UUID, but must not be within the range of the base UUID defined by the Bluetooth SIG
    // - More info in the specification here: https://www.bluetooth.com/specifications/specs/core-specification/
    // - The base UUID is part of the Service Discovery Protocol (SDP) defined by the Bluetooth SIG // TODO: Link/pointer to where to find this in the specification PDF
    static let chatService = CBUUID(string: "00000001-d21a-4245-bcda-1067110a2762") // We use this as our "base" identifier.
    static let chatServiceIncomingReactionsCharacteristic = CBUUID(string: "00000002-d21a-4245-bcda-1067110a2762")
    static let chatServiceOutgoingReactionsCharacteristic = CBUUID(string: "00000003-d21a-4245-bcda-1067110a2762")
    static let chatServiceL2CAPPSMCharacteristic = CBUUID(string: CBUUIDL2CAPPSMCharacteristicString) // Predefined UUID for a characteristic that represent a L2CAP PSM.
}
