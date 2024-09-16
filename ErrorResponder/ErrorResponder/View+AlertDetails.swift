//
//  AlertDetails.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 15/09/2024.
//

import SwiftUI

public struct AlertDetails {
    public struct Action: Identifiable {
        public var id: UUID = UUID()

        let title: String
        let handler: () -> Void
    }

    let title: String
    let message: String
    let actions: [Action]
}

extension View {
    func alert(presenting details: AlertDetails?, isPresented: Binding<Bool>) -> some View {
        alert(details?.title ?? "", isPresented: isPresented) {
            ForEach(details?.actions ?? []) { action in
                Button(action.title, action: action.handler)
            }
        } message: {
            Text(details?.message ?? "")
        }
    }
}
