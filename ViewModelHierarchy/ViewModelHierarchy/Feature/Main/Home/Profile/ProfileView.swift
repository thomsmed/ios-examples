//
//  ProfileView.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 23/07/2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Profile name")
                    .padding()

                Text("Profile details")
                    .padding()
            }
        }
        .navigationTitle("Profile")
    }
}
