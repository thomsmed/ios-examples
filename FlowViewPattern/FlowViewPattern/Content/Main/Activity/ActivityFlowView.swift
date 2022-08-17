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
        ZStack {
            Text("Activity flow")
        }
        .onOpenURL { url in
            guard let path = AppPath.Main.Activity(url) else {
                return
            }

            flowViewModel.go(to: path)
        }
    }
}

extension AppPath.Main.Activity {
    init?(_ url: URL) {
        guard
            let mainPath = AppPath.Main(url),
            case let .activity(subPath) = mainPath
        else {
            return nil
        }

        self = subPath
    }
}

struct ActivityFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityFlowView(flowViewModel: .init())
    }
}
