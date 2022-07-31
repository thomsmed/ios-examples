//
//  OnboardingFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct OnboardingFlowView: View {

    @StateObject var viewModel: OnboardingFlowViewModel

    var body: some View {
        Text("Onboarding flow")
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView(viewModel: .init())
    }
}
