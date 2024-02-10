//
//  ItemView.swift
//  HTTPClient
//
//  Created by Thomas Asheim Smedmann on 10/02/2024.
//

import Foundation
import SwiftUI

struct ItemView: View {
    let text: String
    let edit: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(text)
                .multilineTextAlignment(.leading)
                .padding()
            Spacer()
            Button("Edit", systemImage: "pencil", action: edit)
                .labelStyle(.iconOnly)
                .padding()
            Button("delete", systemImage: "trash.fill", role: .destructive, action: delete)
                .labelStyle(.iconOnly)
                .padding()
        }
    }
}

#Preview {
    ItemView(text: "Hello World!") {
        print("Edit tapped")
    } delete: {
        print("Delete tapped")
    }
}
