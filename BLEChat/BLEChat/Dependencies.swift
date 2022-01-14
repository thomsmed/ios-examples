//
//  Dependencies.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 14/01/2022.
//

import Foundation
import UIKit

struct Dependencies {
    static let chatHostScanner: ChatHostScanner = CoreBluetoothChatHostScanner()
    static let chatHost: ChatHost = CoreBluetoothChatHost(chatBroadcastingName: UIDevice.current.name)
}
