//
//  WelcomeBackView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import SwiftUI

struct WelcomeBackView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Welcome back!")
            Button("Thanks!") {
                dismiss()
            }
        }
    }
}

struct WelcomeBackView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeBackView()
    }
}
