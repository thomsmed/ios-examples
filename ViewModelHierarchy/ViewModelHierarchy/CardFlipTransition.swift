//
//  CardFlipTransition.swift
//  ViewModelHierarchy
//
//  Created by Thomas Asheim Smedmann on 24/07/2024.
//

import SwiftUI

struct CardFlipTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity(phase.isIdentity ? 1.0 : 0.0)
            .rotation3DEffect(phase.rotation, axis: (0,1,0), perspective: 0.3)
    }
}

private extension TransitionPhase {
    var rotation: Angle {
        switch self {
            case .willAppear: return .degrees(180)
            case .identity: return .zero
            case .didDisappear: return .degrees(-180)
        }
    }
}
