//
//  Dependencies.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import UIKit

protocol Dependencies: AnyObject {
    var application: Application { get }
    var appInfoProvider: AppInfoProvider { get }
}

final class DefaultDependencies: Dependencies {
    let application: Application
    let appInfoProvider: AppInfoProvider

    init() {
        application = UIApplication.shared
        appInfoProvider = DefaultAppInfoProvider()
    }
}
