//
//  MockEmojiRepository.swift
//  LiveMockData
//
//  Created by Thomas Asheim Smedmann on 28/08/2022.
//

import Foundation
import Combine

final class MockEmojiRepository {

    private let jsonDecoder = JSONDecoder()

    private let emojisSubject: CurrentValueSubject<[Emoji], Never>

    private let dispatchSource: DispatchSourceFileSystemObject

    private var fileHandle: FileHandle?

    init() {
        guard let path = Bundle.main.path(forResource: "emojis", ofType: "json") else {
            fatalError()
        }

        guard let data = FileManager.default.contents(atPath: path) else {
            fatalError()
        }

        guard let emojis = try? jsonDecoder.decode([Emoji].self, from: data) else {
            fatalError()
        }

        emojisSubject = CurrentValueSubject(emojis)

        guard let fileHandle = FileHandle(forUpdatingAtPath: path) else {
            fatalError()
        }

        dispatchSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileHandle.fileDescriptor,
            eventMask: [.write],
            queue: .main
        )

        dispatchSource.setEventHandler {
            guard let data = FileManager.default.contents(atPath: path) else {
                fatalError()
            }

            guard let emojis = try? self.jsonDecoder.decode([Emoji].self, from: data) else {
                fatalError()
            }

            self.emojisSubject.send(emojis)
        }

        dispatchSource.setCancelHandler {
            do {
                try fileHandle.close()
            } catch {
                fatalError()
            }
        }

        dispatchSource.activate()

        print("Monitoring changes to file at:", path)
        print("Open the file and change the content to have the simulator UI update live!")
    }
}

extension MockEmojiRepository: EmojiRepository {
    var emojis: AnyPublisher<[Emoji], Never> {
        emojisSubject.eraseToAnyPublisher()
    }
}
