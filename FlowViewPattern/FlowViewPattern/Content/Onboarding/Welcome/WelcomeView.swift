//
//  WelcomeView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 13/08/2022.
//

import SwiftUI

struct WelcomeView: View {

    @State var viewModel: WelcomeViewModel

    var body: some View {
        VStack {
            Text("Welcome!")
            Button("Continue") {
                viewModel.continueOnboarding()
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: .init())
    }
}
