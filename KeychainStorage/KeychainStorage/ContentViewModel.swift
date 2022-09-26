//
//  ContentViewModel.swift
//  KeychainStorage
//
//  Created by Thomas Asheim Smedmann on 26/09/2022.
//

import Foundation

private struct MyValue: Codable {
    let thing: String
}

// NSObject and NSCoding (or NSSecureCoding) is needed by NSKeyedArchiver and NSKeyedUnarchiver
class MyClass: NSObject, NSSecureCoding {

    static var supportsSecureCoding: Bool = true

    let thing: String

    init(thing: String) {
        self.thing = thing
    }

    required convenience init?(coder: NSCoder) {
        let thing = coder.decodeObject(forKey: "thing") as? String ?? ""
        self.init(thing: thing)
    }

    func encode(with coder: NSCoder) {
        coder.encode(thing as Any?, forKey: "thing")
    }
}

final class ContentViewModel: ObservableObject {

    private static let key = "key"

    private let secureStorage: SecureStorage = KeychainSecureStorage()

    @Published private(set) var message: String = ""
}

extension ContentViewModel {
    func fetch() {
        do {
//            let _: String = try secureStorage.fetchString(for: Self.key)
//            let _: MyValue = try secureStorage.fetchValue(for: Self.key)
            let _: MyClass = try secureStorage.fetchObject(for: Self.key)

            message = "Fetch success!"
        } catch {
            message = error.localizedDescription
        }
    }

    func persist() {
        let greeting = "Hello there! 👋🧔🏼‍♂️"
        let value = MyValue(thing: greeting)
        let object = MyClass(thing: greeting)

        do {
//            try secureStorage.persistString(greeting, for: Self.key)
//            try secureStorage.persistValue(value, for: Self.key)
            try secureStorage.persistObject(object, for: Self.key)

            message = "Persist success!"
        } catch {
            message = error.localizedDescription
        }
    }

    func delete() {
        do {
            try secureStorage.delete(for: Self.key)

            message = "Delete success!"
        } catch {
            message = error.localizedDescription
        }
    }
}
