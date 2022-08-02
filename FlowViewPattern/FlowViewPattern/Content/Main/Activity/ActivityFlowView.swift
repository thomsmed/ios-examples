//
//  ActivityFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct ActivityFlowView: View {

    @StateObject var flowViewModel: ActivityFlowViewModel

    var body: some View {
        Text("Activity flow")
    }
}

struct ActivityFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityFlowView(flowViewModel: .init())
    }
}
