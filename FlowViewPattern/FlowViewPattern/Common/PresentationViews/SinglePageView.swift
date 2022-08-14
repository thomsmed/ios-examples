//
//  SinglePageView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 11/08/2022.
//

import SwiftUI

struct SinglePageView<Content: View>: View {

    var content: () -> Content

    init(selection: Binding<any Hashable>? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        TabView(content: content)
    }
}

struct SinglePageView_Previews: PreviewProvider {
    static var previews: some View {
        SinglePageView() {

        }
    }
}
