//
//  ItemRepository.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import Foundation

protocol ItemRepository: AnyObject {
    func listItems(_ completion: @escaping ([Item]) -> Void)
    func generateNewItem(_ completion: @escaping (Item) -> Void)
    func deleteItems(olderThan expirationDate: Date, completion: @escaping () -> Void)
}

final class DefaultItemRepository {

    private let itemRepositoryItemsKey = "com.thomsmed.ItemRepository.Items"
    private let itemRepositorySequenceNumberKey = "com.thomsmed.ItemRepository.SequenceNumber"

    private let queue = DispatchQueue(
        label: "com.thomsmed.ItemRepositoryQueue",
        qos: .background,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: .global(qos: .background)
    )

    private let userDefaults = UserDefaults.standard

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private var cachedItems: [Item]?

    private func items() -> [Item] {
        Thread.sleep(forTimeInterval: 3) // Do not do this at home

        guard let data = userDefaults.data(forKey: itemRepositoryItemsKey) else {
            return []
        }

        return (try? jsonDecoder.decode([Item].self, from: data)) ?? []
    }

    private func store(items: [Item]) {
        Thread.sleep(forTimeInterval: 3) // Do not do this at home

        guard let data = try? jsonEncoder.encode(items) else {
            return
        }

        userDefaults.set(data, forKey: itemRepositoryItemsKey)
    }

    private func generateSequenceNumber() -> Int {
        let nextSequenceNumber = userDefaults.integer(forKey: itemRepositorySequenceNumberKey) + 1

        userDefaults.set(nextSequenceNumber, forKey: itemRepositorySequenceNumberKey)

        return nextSequenceNumber
    }
}

extension DefaultItemRepository: ItemRepository {

    func listItems(_ completion: @escaping ([Item]) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 3) // Do not do this at home

            if let items = self.cachedItems {
                return completion(items)
            }

            let items = self.items()

            self.cachedItems = items

            completion(items)
        }
    }

    func generateNewItem(_ completion: @escaping (Item) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 5) // Do not do this at home

            var items = self.items()

            let item: Item = .init(
                text: "Item \(self.generateSequenceNumber())",
                timestamp: .now
            )

            items.append(item)

            self.store(items: items)

            self.cachedItems = items // Update cache

            completion(item)
        }
    }

    func deleteItems(olderThan expirationDate: Date, completion: @escaping () -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 15) // Do not do this at home

            var items = self.items()

            items.removeAll(where: { item in
                return item.timestamp < expirationDate
            })

            self.store(items: items)

            self.cachedItems = items // Update cache

            completion()
        }
    }
}
