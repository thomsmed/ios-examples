//
//  BluetoothError.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 18/01/2022.
//

import Foundation

enum BluetoothError: Error {
    case invalidState
    case unknownPeripheral
    case connectionFailure
}
