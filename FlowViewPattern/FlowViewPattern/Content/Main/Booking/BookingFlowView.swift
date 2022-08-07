//
//  BookingFlowView.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 31/07/2022.
//

import SwiftUI

struct BookingFlowView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Booking flow")
        Button("Done") {
            dismiss()
        }
    }
}

struct BookingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        BookingFlowView()
    }
}
