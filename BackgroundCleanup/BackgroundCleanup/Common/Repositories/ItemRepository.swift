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

    private let itemRepositoryKey = "com.thomsmed.ItemRepository"

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

    private func loadItems() -> [Item] {
        guard let data = userDefaults.data(forKey: itemRepositoryKey) else {
            return []
        }

        return (try? jsonDecoder.decode([Item].self, from: data)) ?? []
    }

    private func store(items: [Item]) {
        guard let data = try? jsonEncoder.encode(items) else {
            return
        }

        userDefaults.set(data, forKey: itemRepositoryKey)
    }
}

extension DefaultItemRepository: ItemRepository {

    func listItems(_ completion: @escaping ([Item]) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 3) // Do not do this at home

            if let items = self.cachedItems {
                return completion(items)
            }

            Thread.sleep(forTimeInterval: 3) // Do not do this at home

            let items = self.loadItems()

            self.cachedItems = items

            completion(items)
        }
    }

    func generateNewItem(_ completion: @escaping (Item) -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 5) // Do not do this at home

            var items = self.loadItems()

            let item: Item = .init(text: "Item \(items.count)", timestamp: .now)

            items.append(item)

            self.store(items: items)

            completion(item)
        }
    }

    func deleteItems(olderThan expirationDate: Date, completion: @escaping () -> Void) {
        queue.async {
            Thread.sleep(forTimeInterval: 15) // Do not do this at home

            var items = self.loadItems()

            items.removeAll(where: { item in
                return item.timestamp < expirationDate
            })

            self.store(items: items)

            completion()
        }
    }
}
