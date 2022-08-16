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
        .onOpenURL { url in
            guard let path = AppPath.Main.Profile(url) else {
                return
            }

            flowViewModel.go(to: path)
        }
    }
}

extension AppPath.Main.Profile {
    init?(_ url: URL) {
        guard
            let mainPath = AppPath.Main(url),
            case let .profile(subPath) = mainPath
        else {
            return nil
        }

        self = subPath
    }
}

struct ProfileFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFlowView(flowViewModel: .init())
    }
}
