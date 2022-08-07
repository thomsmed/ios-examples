//
//  ExploreFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ExploreFlowView: View {

    @StateObject var flowViewModel: ExploreFlowViewModel

    var body: some View {
        VStack {
            Text("Explore flow")
            Button("Booking") {
                flowViewModel.continueToBooking()
            }
        }
    }
}

struct ExploreFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreFlowView(
            flowViewModel: .init(
                flowCoordinator: MockFlowCoordinator.shared
            )
        )
    }
}
