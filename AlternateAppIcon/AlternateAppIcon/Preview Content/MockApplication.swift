//
//  MockApplication.swift
//  AlternateAppIcon
//
//  Created by Thomas Asheim Smedmann on 25/06/2023.
//

import Foundation

final class MockApplication: Application {
    var alternateIconName: String? = nil

    func setAlternateIconName(_ alternateIconName: String?, completionHandler: ((Error?) -> Void)?) {
        completionHandler?(nil)
    }
}
