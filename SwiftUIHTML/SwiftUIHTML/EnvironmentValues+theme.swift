//
//  EnvironmentValues+theme.swift
//  SwiftUIHTML
//
//  Created by Thomas Asheim Smedmann on 13/07/2023.
//

import SwiftUI

struct Theme {
    let textPrimary: UIColor
    let textSecondary: UIColor
    let textInteractive: UIColor
}

extension Theme {
    static let `default` = Theme(
        textPrimary: .label,
        textSecondary: .secondaryLabel,
        textInteractive: .systemGreen
    )
}

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = .default
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
