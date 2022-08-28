//
//  EmojiRepository.swift
//  LiveMockData
//
//  Created by Thomas Asheim Smedmann on 28/08/2022.
//

import Foundation
import Combine

typealias Emoji = String

protocol EmojiRepository {
    var emojis: AnyPublisher<[Emoji], Never> { get }
}
