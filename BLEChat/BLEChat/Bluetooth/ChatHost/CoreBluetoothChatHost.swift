//
//  CoreBluetoothChatHost.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 14/01/2022.
//

import Foundation
import Combine
import CoreBluetooth

// MARK: CBManagerState+asCHState

fileprivate extension CBManagerState {
    var asCHState: ChatHostState {
        switch self {
        case .poweredOn:
            return .ready
        case .unauthorized:
            return .unauthorised
        default:
            return .off
        }
    }
}

// MARK: CoreBluetoothChatHost

final class CoreBluetoothChatHost: NSObject {

    private lazy var serialQueue = DispatchQueue(
        label: "\(String(describing: Self.self)).\(String(describing: DispatchQueue.self))",
        qos: .userInitiated,
        attributes: [],
        target: .global(qos: .userInitiated)
    )

    private lazy var peripheralManager = CBPeripheralManager(delegate: self, queue: serialQueue)

    private lazy var stateSubject = CurrentValueSubject<ChatHostState, Never>(peripheralManager.state.asCHState)

    private let reactionsSubject = PassthroughSubject<String, Never>()
    private let messagesSubject = PassthroughSubject<String, Never>()

    private let chatBroadcastingName: String

    private var activeL2CAPChannel: CBL2CAPChannel?
    private var lastOutgoingReaction: String = ""

    init(chatBroadcastingName: String) {
        self.chatBroadcastingName = chatBroadcastingName
    }
}

// MARK: CBPeripheralManagerDelegate

extension CoreBluetoothChatHost: CBPeripheralManagerDelegate {

    // MARK: State and advertisement management

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        stateSubject.send(peripheral.state.asCHState)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        if let error = error {
            print(error)
        } else {
            peripheral.add(ChatServiceFactory.make(with: PSM))
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print(error)
        } else {
            let services: [CBUUID] = [
                AssignedNumbers.chatService
            ]
            // Max broadcasting size (in total) = 28 bytes.
            // If Service UUIDs take up more space than this, the Local Name (CBAdvertisementDataLocalNameKey) get 10 bytes in the scan response package load.
            // Apple's documentation: https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager/1393252-startadvertising
            peripheral.startAdvertising([
                CBAdvertisementDataLocalNameKey: chatBroadcastingName,
                CBAdvertisementDataServiceUUIDsKey: services
            ])
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print(error) // Invalid advertisement data, or BLE peripheral busy / unavailable
        }
    }

    // MARK: Request handeling

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // Apple's documentation:
        // https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonPeripheralRoleTasks/PerformingCommonPeripheralRoleTasks.html#//apple_ref/doc/uid/TP40013257-CH4-SW6
        guard request.characteristic.uuid == AssignedNumbers.chatServiceOutgoingReactionsCharacteristic else {
            return peripheral.respond(to: request, withResult: .readNotPermitted)
        }

        let lengthOfLastOutgoingReaction = lastOutgoingReaction.count
        guard request.offset > -1 && request.offset < lengthOfLastOutgoingReaction else {
            return peripheral.respond(to: request, withResult: .invalidOffset)
        }

        request.value = lastOutgoingReaction.data(using: .utf8)?.subdata(in: request.offset..<lengthOfLastOutgoingReaction)
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        // Apple's documentation:
        // https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/PerformingCommonPeripheralRoleTasks/PerformingCommonPeripheralRoleTasks.html#//apple_ref/doc/uid/TP40013257-CH4-SW6
        // Important: Only call respond once per delegate callback (see the documentation for more info)
        var reactions: [String] = []
        for request in requests {
            guard request.characteristic.uuid == AssignedNumbers.chatServiceIncomingReactionsCharacteristic else {
                return peripheral.respond(to: requests[0], withResult: .writeNotPermitted)
            }
            guard let data = request.value, let reaction = String(data: data, encoding: .utf8) else {
                return peripheral.respond(to: requests[0], withResult: .requestNotSupported)
            }
            reactions.append(reaction)
        }
        peripheral.respond(to: requests[0], withResult: .success)
        reactions.forEach { reaction in
            reactionsSubject.send(reaction)
        }
    }

    // MARK: Subscription handling

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("centralDidSubscribeToCharacteristic")
        // central.maximumUpdateValueLength // Use this value to limit notification data if you want to make sure all the data is sent with the notification. TODO: Investigate this!
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("centralDidUnsubscribeFromCharacteristic")
        // Useful if you want to track wether you should update a vale or not. E.g. if you do not want to update a value that has no subscribers to it.
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        // Called if a previous call to .updateValue(_:, for:onSubscribedCentrals:) failed due to full transmit queue.
        guard let data = lastOutgoingReaction.data(using: .utf8) else { return }
        peripheral.updateValue(data, for: ChatServiceFactory.outgoingReactionsCharacteristic, onSubscribedCentrals: nil)
    }

    // MARK: L2CAP Channel streaming

    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        if let error = error {
            print(error)
        }
        guard let channel = channel else { return }
        dismantleL2CAPChannel() // Making sure only one channel is active at the time
        // More about working with streams here:
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
        // TODO: Add links to docs about RunLoops / RunLoop modes
        channel.inputStream.delegate = self
        channel.inputStream.schedule(in: .main, forMode: .default)
        channel.inputStream.open()
        channel.outputStream.delegate = self
        channel.outputStream.schedule(in: .main, forMode: .default)
        channel.outputStream.open()
        activeL2CAPChannel = channel
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        if let error = error {
            print(error)
        }
        dismantleL2CAPChannel()
    }

    private func dismantleL2CAPChannel() {
        // More about working with streams here:
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
        // TODO: Add links to docs about RunLoops / RunLoop modes
        guard let channel = activeL2CAPChannel else { return }
        channel.inputStream.close()
        channel.inputStream.remove(from: .main, forMode: .default)
        channel.outputStream.close()
        channel.outputStream.remove(from: .main, forMode: .default)
        activeL2CAPChannel = nil
    }
}

// MARK: StreamDelegate

extension CoreBluetoothChatHost: StreamDelegate {

    // More about working with streams here:
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1
    func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            print("\(stream is InputStream ? "input" : "output")Stream:openCompleted")
        case .hasBytesAvailable:
            print("\(stream is InputStream ? "input" : "output")Stream:hasBytesAvailable")
            guard let inputStream = stream as? InputStream else { return }
            let bufferSize = 255 // Just a random number for the purpose of this example
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
            serialQueue.async {
                self.dismantleL2CAPChannel()
            }
        case .errorOccurred:
            print("\(stream is InputStream ? "input" : "output")Stream:errorOccurred")
            serialQueue.async {
                self.dismantleL2CAPChannel()
            }
        default:
            print("\(stream is InputStream ? "input" : "output")Stream:unknownEventCode")
        }
    }
}

// MARK: ChatHost

extension CoreBluetoothChatHost: ChatHost {

    var state: AnyPublisher<ChatHostState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var reactions: AnyPublisher<String, Never> {
        reactionsSubject.eraseToAnyPublisher()
    }

    var messages: AnyPublisher<String, Never> {
        messagesSubject.eraseToAnyPublisher()
    }

    func startBroadcast() {
        serialQueue.async {
            guard self.stateSubject.value == .ready, self.activeL2CAPChannel == nil else { return }
            self.stateSubject.send(.broadcasting)
            self.peripheralManager.publishL2CAPChannel(withEncryption: true)
        }
    }

    func stopBroadcast() {
        serialQueue.async {
            guard self.stateSubject.value == .broadcasting else { return }
            self.peripheralManager.stopAdvertising()
            self.peripheralManager.removeAllServices()
            if let activeL2CAPChannel = self.activeL2CAPChannel {
                self.peripheralManager.unpublishL2CAPChannel(activeL2CAPChannel.psm)
            }
            self.stateSubject.send(.ready)
        }
    }

    func submit(message: String) {
        serialQueue.async {
            guard
                let channel = self.activeL2CAPChannel,
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
                self.stateSubject.value == .broadcasting,
                let data = reaction.data(using: .utf8)
            else { return }
            self.lastOutgoingReaction = reaction
            if !self.peripheralManager.updateValue(
                data,
                for: ChatServiceFactory.outgoingReactionsCharacteristic,
                onSubscribedCentrals: nil
            ) {
                print("Transmit queue is full. Delegate will be notified when the queue is ready.")
            }
        }
    }
}
