//
//  ProfileFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import SwiftUI

struct ProfileFlowView: View {

    @StateObject var flowViewModel: ProfileFlowViewModel

    var body: some View {
        VStack {
            Text("Profile flow")
            Button("Toggle") {
                flowViewModel.toggle()
            }
        }
    }
}

struct ProfileFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFlowView(flowViewModel: .init())
    }
}
