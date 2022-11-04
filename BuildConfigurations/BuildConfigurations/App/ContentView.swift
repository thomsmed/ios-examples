//
//  ContentView.swift
//  BuildConfigurations
//
//  Created by Thomas Asheim Smedmann on 04/11/2022.
//

import SwiftUI

struct ContentView: View {

    let properties: [String: String]

    var someProperty: String {
        "Some property: \(properties["SomeProperty"] ?? "")"
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(Constants.hello)
            Text(someProperty)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(properties: [:])
    }
}
