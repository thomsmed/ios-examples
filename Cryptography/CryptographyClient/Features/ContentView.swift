//
//  ContentView.swift
//  CryptographyClient
//
//  Created by Thomas Asheim Smedmann on 11/08/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: Model = .init()

    var body: some View {
        NavigationStack(path: $viewModel.pages) {
            List(Page.allCases) { page in
                NavigationLink(value: page) {
                    Text(page.title)
                }
            }
            .navigationTitle("Cryptography with iOS")
            .navigationDestination(for: Page.self) { page in
                switch page {
                    case .hashFunctions:
                        HashFunctionsView()
                            .navigationTitle(page.title)

                    case .symmetricKeyCryptography:
                        SymmetricKeyView()
                            .navigationTitle(page.title)

                    case .asymmetricKeyCryptography:
                        AsymmetricKeyView()
                            .navigationTitle(page.title)

                    case .messageAuthenticationCodes:
                        HStack {
                            Text(page.title)
                        }
                        .navigationTitle(page.title)

                    case .certificatePinning:
                        CertificatePinningView()
                            .navigationTitle(page.title)
                }
            }
        }
    }
}

extension ContentView {
    enum Page: CaseIterable, Identifiable {
        case hashFunctions
        case symmetricKeyCryptography
        case asymmetricKeyCryptography
        case messageAuthenticationCodes
        case certificatePinning

        var id: Self { self }

        var title: String {
            switch self {
                case .hashFunctions: return "Hash Functions"
                case .symmetricKeyCryptography: return "Symmetric Key Cryptography"
                case .asymmetricKeyCryptography: return "Asymmetric/Public Key Cryptography"
                case .messageAuthenticationCodes: return "Message Authentication Codes"
                case .certificatePinning: return "Certificate Pinning"
            }
        }
    }
}

extension ContentView {
    final class Model: ObservableObject {
        @Published var pages: [Page] = []
    }
}

#Preview {
    ContentView()
}
