//
//  HashFunctionsView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 20/08/2023.
//

import SwiftUI
import Combine
import CryptoKit

struct HashFunctionsView: View {
    @StateObject private var viewModel: Model = .init()

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(
                        "Write something to hash...",
                        text: $viewModel.input
                    )
                    .onSubmit(viewModel.didSubmit)

                    Button("Collect", action: viewModel.didSubmit)
                }

                Picker(
                    "Hash function",
                    selection: $viewModel.selectedHashFunction
                ) {
                    ForEach(HashFunction.allCases) { hashFunction in
                        Text(hashFunction.title).tag(hashFunction)
                    }
                }
            }

            Section("Digest") {
                Text(viewModel.input)
                Text(viewModel.hashedInput)
            }

            Section("Collected Digest") {
                Text(viewModel.collectedInput.joined())
                Text(viewModel.hashedCollectedInput)
            }
        }
    }
}

extension HashFunctionsView {
    enum HashFunction: CaseIterable, Identifiable {
        case sha256
        case sha384
        case sha512

        var id: Self { self }

        var title: String {
            switch self {
                case .sha256: return "SHA256"
                case .sha384: return "SHA384"
                case .sha512: return "SHA512"
            }
        }
    }
}

extension HashFunctionsView {
    final class Model: ObservableObject {
        @Published var selectedHashFunction: HashFunction = .sha256

        @Published var input: String = ""

        @Published private(set) var collectedInput: [String] = []

        @Published private(set) var hashedInput: String = ""

        @Published private(set) var hashedCollectedInput: String = ""

        private var subscriptions = Set<AnyCancellable>()

        init() {
            $selectedHashFunction.sink { [weak self] selectedHashFunction in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                populateHashedInput(from: input)

                populateHashedCollectedInput(from: collectedInput)
            }
            .store(in: &subscriptions)

            $input.sink { [weak self] input in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                populateHashedInput(from: input)
            }
            .store(in: &subscriptions)
        }

        private func populateHashedInput(from input: String) {
            guard let inputData = input.data(using: .utf8) else {
                return assertionFailure("Why did this happen?")
            }

            switch selectedHashFunction {
                case .sha256:
                    SHA256.hash(data: inputData).withUnsafeBytes { buffer in
                        hashedInput = buffer.map { byte in
                            String(format: "%02x", byte)
                        }.joined()
                    }

                case .sha384:
                    SHA384.hash(data: inputData).withUnsafeBytes { buffer in
                        hashedInput = buffer.map { byte in
                            String(format: "%02x", byte)
                        }.joined()
                    }

                case .sha512:
                    SHA512.hash(data: inputData).withUnsafeBytes { buffer in
                        hashedInput = buffer.map { byte in
                            String(format: "%02x", byte)
                        }.joined()
                    }
            }
        }

        private func populateHashedCollectedInput(from collectedInput: [String]) {
            var hasher: any CryptoKit.HashFunction

            switch selectedHashFunction {
                case .sha256:
                    hasher = SHA256()

                case .sha384:
                    hasher = SHA384()

                case .sha512:
                    hasher = SHA512()
            }

            collectedInput.forEach { input in
                guard let inputData = input.data(using: .utf8) else {
                    return assertionFailure("Why did this happen?")
                }

                hasher.update(data: inputData)
            }

            hasher.finalize().withUnsafeBytes { buffer in
                hashedCollectedInput = buffer.map { byte in
                    String(format: "%02x", byte)
                }.joined()
            }
        }
    }
}

extension HashFunctionsView.Model {
    func didSubmit() {
        collectedInput.append(input)

        populateHashedCollectedInput(from: collectedInput)

        input = ""
    }
}

#Preview {
    HashFunctionsView()
}
