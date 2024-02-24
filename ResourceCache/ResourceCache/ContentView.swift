//
//  ContentView.swift
//  ResourceCache
//
//  Created by Thomas Asheim Smedmann on 24/02/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.topTextRows, id: \.0) { row in
                        HStack {
                            Spacer()
                            Text(row.1)
                                .padding()
                            Spacer()
                        }
                    }

                    ForEach(viewModel.middleImageRows, id: \.0) { row in
                        HStack {
                            Spacer()
                            if let uiImage = row.1 {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 64)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 64)
                            }
                            Spacer()
                        }
                        .task {
                            await viewModel.loadImage(for: row.0)
                        }
                    }

                    ForEach(viewModel.bottomTextRows, id: \.0) { row in
                        HStack {
                            Spacer()
                            Text(row.1)
                                .padding()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Resource Cache")
        }
    }
}

extension ContentView {
    @MainActor final class ViewModel: ObservableObject {
        private let resourceCache = TaskSpawningResourceCache()
        // private let resourceCache = TaskSpawningCancelingResourceCache()
        // private let resourceCache = ContinuationCreatingResourceCache()
        // private let resourceCache = ContinuationCreatingCancelingResourceCache()
        // private let resourceCache = ContinuationCreatingTaskSpawningCancelingResourceCache()

        var topTextRows: [(UUID, String)] = (0..<30).map { _ in (UUID(), "Some text before Image rows") }
        @Published var middleImageRows: [(UUID, UIImage?)] = (0..<10).map { _ in (UUID(), nil) }
        var bottomTextRows: [(UUID, String)] = (0..<30).map { _ in (UUID(), "Some text after Image rows") }

        func loadImage(for uuid: UUID) async {
            print("Resource requesting Task initiated for \(uuid)")

            let imageData = await resourceCache.resource

            if Task.isCancelled {
                return print("Resource requesting Task canceled for \(uuid)")
            }

            guard let imageData else {
                return
            }

            guard let index = middleImageRows.firstIndex(where: { $0.0 == uuid }) else {
                return
            }

            middleImageRows[index] = (uuid, UIImage(data: imageData))
        }
    }
}

#Preview {
    ContentView()
}
