//
//  ProfileView.swift
//  ActionableViewModel
//
//  Created by Thomas Asheim Smedmann on 15/06/2024.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            Text("Profile name")
                .padding()

            Text("Profile details")
                .padding()
        }
        .navigationTitle("Profile")
    }
}
