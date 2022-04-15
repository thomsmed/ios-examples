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
    // - Can be any 128 bit UUID, but must not collide with the predefined UUIDs by the Bluetooth SIG.
    // - The base UUID for all predefined UUIDs defined by SIG is 00000000-0000-1000-8000-00805F9B34FB,
    //   where the 16 most significant bits vary for the reserved predefined UUIDs by Bluetooth SIG.
    //   These UUID is often referred to by only these 16 most significant bits.
    //   Check out the official list at: https://www.bluetooth.com/specifications/assigned-numbers/
    // - A common way to define custom UUIDs, is to start by defining your own base UUID.
    //   And then vary the 16 most significant bits for all your custom UUIDs.
    // - More info in the core specification: https://www.bluetooth.com/specifications/specs/core-specification/
    // We have defined 00000000-d21a-4245-bcda-1067110a2762 as our own custom base UUID.
    // Then all our custom UUIDs only vary in the first 16 most significant bits.
    static let chatService = CBUUID(string: "00000001-d21a-4245-bcda-1067110a2762")
    static let chatServiceIncomingReactionsCharacteristic = CBUUID(string: "00000002-d21a-4245-bcda-1067110a2762")
    static let chatServiceOutgoingReactionsCharacteristic = CBUUID(string: "00000003-d21a-4245-bcda-1067110a2762")
    static let chatServiceL2CAPPSMCharacteristic = CBUUID(string: CBUUIDL2CAPPSMCharacteristicString) // Predefined UUID for a characteristic that represent a L2CAP PSM.
}
