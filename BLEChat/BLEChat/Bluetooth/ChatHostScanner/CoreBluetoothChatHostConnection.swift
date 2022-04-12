//
//  CoreBluetoothChatHostConnection.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 18/01/2022.
//

import Foundation
import CoreBluetooth
import Combine

final class CoreBluetoothChatHostConnection: NSObject {

    private let serialQueue: DispatchQueue
    private let centralManager: CBCentralManager

    private let stateSubject = CurrentValueSubject<ChatHostConnectionState, Never>(.connecting)
    private let reactionsSubject = PassthroughSubject<String, Never>()
    private let messagesSubject = PassthroughSubject<String, Never>()

    private var peripheral: CBPeripheral?
    private var discoveryProgression = 0
    private var connectionProgression = 0
    private var didEncounterErrors = false
    private var l2capChannel: CBL2CAPChannel?

    init(serialQueue: DispatchQueue, centralManager: CBCentralManager) {
        self.serialQueue = serialQueue
        self.centralManager = centralManager
    }

    func connected(to peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([
            AssignedNumbers.chatService,
        ])
        self.peripheral = peripheral
    }

    func disconnected(from peripheral: CBPeripheral, with error: Error?) {
        self.peripheral = nil
        dismantleL2CAPChannel()
        stateSubject.send(.disconnected)
    }
}

// MARK: CBPeripheralDelegate

extension CoreBluetoothChatHostConnection: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        didEncounterErrors = error != nil
        let services = peripheral.services ?? []
        discoveryProgression += services.count
        services.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
        checkDiscoveryProgression()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didEncounterErrors = error != nil
        let characteristics = service.characteristics ?? []
        discoveryProgression += characteristics.count
        characteristics.forEach { characteristic in
            peripheral.discoverDescriptors(for: characteristic)
        }
        discoveryProgression -= 1
        checkDiscoveryProgression()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        didEncounterErrors = error != nil
        discoveryProgression -= 1
        checkDiscoveryProgression()
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // This is called when a disconnection occur or when the peripheral does not broadcast these services anymore.
        // NOTE: When an app, acting as a peripheral, goes into background mode, the system (iOS) removes services added by the app from the broadcast.
        guard self.stateSubject.value == .connected else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        didEncounterErrors = error != nil
        guard let channel = channel else {
            didEncounterErrors = true
            return checkConnectionProgression()
        }
        prepare(l2capChannel: channel)
        connectionProgression -= 1
        checkConnectionProgression()
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        didEncounterErrors = error != nil
        guard characteristic.isNotifying else {
            didEncounterErrors = true
            return checkConnectionProgression()
        }
        connectionProgression -= 1
        checkConnectionProgression()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // This is were you would verify that a write to a peripheral was successful.
        if let error = error {
            print(error)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // This method is called both when a read is initiated by the central, or when the peripheral has notified that a new value is available.
        if characteristic.uuid == AssignedNumbers.chatServiceL2CAPPSMCharacteristic {
            guard let data = characteristic.value else {
                didEncounterErrors = true
                return checkConnectionProgression()
            }
            let l2capChannelPSM = data.withUnsafeBytes { ptr in
                ptr.load(as: CBL2CAPPSM.self)
            }
            peripheral.openL2CAPChannel(l2capChannelPSM)
        } else if characteristic.uuid == AssignedNumbers.chatServiceOutgoingReactionsCharacteristic {
            if let data = characteristic.value, let reaction = String(data: data, encoding: .utf8) {
                reactionsSubject.send(reaction)
            }
        }
    }

    private func checkDiscoveryProgression() {
        if didEncounterErrors {
            stateSubject.send(.error)
        } else if discoveryProgression == 0 {
            configureNotifications()
            fetchL2CAPChannelSMP()
        }
    }

    private func checkConnectionProgression() {
        if didEncounterErrors {
            stateSubject.send(.error)
        } else if connectionProgression == 0 {
            stateSubject.send(.connected)
        }
    }

    private func configureNotifications() {
        guard
            let peripheral = peripheral,
            let chatService = peripheral.services?.first(where: { service in
                service.uuid == AssignedNumbers.chatService
            }),
            let outboxCharacteristic = chatService.characteristics?.first(where: { characteristic in
                characteristic.uuid == AssignedNumbers.chatServiceOutgoingReactionsCharacteristic
            })
        else {
            didEncounterErrors = true
            return checkConnectionProgression()
        }
        connectionProgression += 1
        peripheral.setNotifyValue(true, for: outboxCharacteristic)
    }

    private func fetchL2CAPChannelSMP() {
        guard
            let peripheral = peripheral,
            let chatService = peripheral.services?.first(where: { service in
                service.uuid == AssignedNumbers.chatService
            }),
            let l2capChannelCharacteristic = chatService.characteristics?.first(where: { characteristic in
                characteristic.uuid == AssignedNumbers.chatServiceL2CAPPSMCharacteristic
            })
        else {
            didEncounterErrors = true
            return checkConnectionProgression()
        }
        connectionProgression += 1
        peripheral.readValue(for: l2capChannelCharacteristic)
    }

    private func prepare(l2capChannel channel: CBL2CAPChannel) {
        // More about working with streams here:
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
        // TODO: Add links to docs about RunLoops / RunLoop modes
        channel.inputStream.delegate = self
        channel.inputStream.schedule(in: .main, forMode: .default)
        channel.inputStream.open()
        channel.outputStream.delegate = self
        channel.outputStream.schedule(in: .main, forMode: .default)
        channel.outputStream.open()
        l2capChannel = channel
    }

    private func dismantleL2CAPChannel() {
        // More about working with streams here:
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
        // TODO: Add links to docs about RunLoops / RunLoop modes
        guard let channel = l2capChannel else { return }
        channel.inputStream.close()
        channel.inputStream.remove(from: .main, forMode: .default)
        channel.outputStream.close()
        channel.outputStream.remove(from: .main, forMode: .default)
        l2capChannel = nil
    }
}

// MARK: StreamDelegate

extension CoreBluetoothChatHostConnection: StreamDelegate {

    // More about working with streams here:
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
    func stream(_ stream: Stream, handle event: Stream.Event) {
        switch event {
        case .openCompleted:
            print("\(stream is InputStream ? "input" : "output")Stream:openCompleted")
        case .hasBytesAvailable:
            print("\(stream is InputStream ? "input" : "output")Stream:hasBytesAvailable")
            guard let inputStream = stream as? InputStream else { return }
            let bufferSize = 255
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            var totalNumberOfBytesRead = 0
            while inputStream.hasBytesAvailable && totalNumberOfBytesRead < bufferSize {
                let numberOfBytesRead = inputStream.read(buffer.advanced(by: totalNumberOfBytesRead),
                                                         maxLength: bufferSize - totalNumberOfBytesRead)
                if numberOfBytesRead < 0, let error = inputStream.streamError {
                    return print(error)
                } else if numberOfBytesRead == 0 {
                    return
                }
                totalNumberOfBytesRead += numberOfBytesRead
            }
            let data = Data(buffer: UnsafeMutableBufferPointer(start: buffer, count: totalNumberOfBytesRead))
            guard let message = String(data: data, encoding: .utf8) else { return }
            serialQueue.async {
                self.messagesSubject.send(message)
            }
        case .hasSpaceAvailable:
            print("\(stream is InputStream ? "input" : "output")Stream:hasSpaceAvailable")
        case .endEncountered:
            print("\(stream is InputStream ? "input" : "output")Stream:endEncountered")
            disconnect()
        case .errorOccurred:
            print("\(stream is InputStream ? "input" : "output")Stream:errorOccurred")
            disconnect()
        default:
            print("\(stream is InputStream ? "input" : "output")Stream:unknownEventCode")
        }
    }
}

// MARK: ChatHostConnection

extension CoreBluetoothChatHostConnection: ChatHostConnection {

    var state: AnyPublisher<ChatHostConnectionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var messages: AnyPublisher<String, Never> {
        messagesSubject.eraseToAnyPublisher()
    }

    var reactions: AnyPublisher<String, Never> {
        reactionsSubject.eraseToAnyPublisher()
    }

    func submit(message: String) {
        serialQueue.async {
            guard
                let channel = self.l2capChannel,
                let data = message.data(using: .utf8)
            else { return }
            let dataSize = data.count
            data.withUnsafeBytes { ptr in
                guard let startOfData = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
                var totalNumberOfBytesWritten = 0
                while channel.outputStream.hasSpaceAvailable && totalNumberOfBytesWritten < dataSize {
                    let numberOfBytesWritten = channel.outputStream.write(startOfData.advanced(by: totalNumberOfBytesWritten),
                                                                          maxLength: dataSize - totalNumberOfBytesWritten)
                    if numberOfBytesWritten < 0, let error = channel.outputStream.streamError {
                        return print(error)
                    } else if numberOfBytesWritten == 0 {
                        return
                    }
                    totalNumberOfBytesWritten += numberOfBytesWritten
                }
            }
        }
    }

    func submit(reaction: String) {
        serialQueue.async {
            guard
                self.stateSubject.value == .connected,
                let data = reaction.data(using: .utf8),
                let peripheral = self.peripheral,
                let chatService = peripheral.services?.first(where: { service in
                    service.uuid == AssignedNumbers.chatService
                }),
                let inboxCharacteristic = chatService.characteristics?.first(where: { characteristic in
                    characteristic.uuid == AssignedNumbers.chatServiceIncomingReactionsCharacteristic
                })
            else { return }
            peripheral.writeValue(data, for: inboxCharacteristic, type: .withResponse)
        }
    }

    func disconnect() {
        serialQueue.async {
            guard self.stateSubject.value == .connected, let peripheral = self.peripheral else { return }
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
